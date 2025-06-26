import logging
import logging.config
import shutil
import sqlite3
import subprocess
import sys
from pathlib import Path

logger: logging.Logger = logging.getLogger(__name__)

db_path: Path = Path("build/route-editor.sqlite")
overwrite_db: bool = True

# Load test data for development or creation of example projects
load_test_data: bool = True
test_data_db: str = "test/data/route-editor.sqlite"

sql_scripts: list[str] = [
    "models/init_db.sql",
    "models/value_catalog.sql",
    "models/schema.sql",
    "models/route_manager.sql",
]


def main() -> None:
    logging.config.dictConfig(LOGGING_CONFIG)

    handle_existing_db(db_path, overwrite_db)

    logger.info("Applying the schema to the database")
    apply_sql_scripts(db_path.as_posix(), sql_scripts)

    logger.info("Create empty database template")
    empty_db_path = db_path.with_name(db_path.name + ".empty")
    shutil.copyfile(db_path, empty_db_path)

    if load_test_data:
        logger.info("Loading test data from the temporary dump")
        copy_test_data(db_path.as_posix(), test_data_db)

    logger.info(f"Successfully created {db_path}")


def handle_existing_db(db_path: Path, overwrite_db: bool) -> None:
    if db_path.exists() and not overwrite_db:
        logger.error(
            f"Database {db_path} already exists. "
            "Use overwrite_db=True to recreate it. "
            "Stopp building the database."
        )
        sys.exit(1)

    if db_path.exists():
        try:
            db_path.unlink()
            logger.info(f"Successfully deleted {db_path}")
        except PermissionError as e:
            logger.exception(f"Failed to delete {db_path}: {e}")
            sys.exit(1)


def apply_sql_scripts(db_path: str, sql_scripts: list[str]) -> None:
    connection = sqlite3.connect(db_path)
    connection.enable_load_extension(True)
    cursor = connection.cursor()

    for script in sql_scripts:
        logger.info(f"Applying {script}")
        with open(script) as f:
            cursor.executescript(f.read())

    connection.commit()
    connection.close()


def copy_test_data(target_db: str, source_db: str) -> None:
    tables: list[str] = [
        "data_source",
        "route",
        "segment",
        "section",
        "section_segment",
    ]

    for table in tables:
        command = [
            "ogr2ogr",
            "-append",
            "-update",
            target_db,
            source_db,
            table,
        ]

        try:
            logger.info(f"Executing command: {' '.join(command)}")
            subprocess.run(command, check=True, capture_output=True)
        except subprocess.CalledProcessError as e:
            logger.error(f"Command failed: {e}")
            sys.exit(1)


LOGGING_CONFIG = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "simple": {"format": "%(levelname)s - %(message)s"},
        "extended": {"format": "%(asctime)s - %(levelname)s - %(message)s"},
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "simple",
            "level": logging.INFO,
        },
    },
    "loggers": {
        "__main__": {
            "handlers": ["console"],
            "level": logging.INFO,
            "propagate": False,
        },
    },
}


if __name__ == "__main__":
    main()
