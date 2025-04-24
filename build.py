import logging
import sqlite3
from pathlib import Path
import subprocess
import sys
import logging.config


logger = logging.getLogger(__name__)

db_path = Path("build/route-editor.sqlite")
overwrite_db = True
load_test_data = False

sql_scripts = [
    "models/init_db.sql",
    "models/value_catalog.sql",
    "models/schema.sql",
    "models/route_manager.sql",
]


def main():
    logging.config.dictConfig(LOGGING_CONFIG)

    if db_path.exists() and not overwrite_db:
        logger.error(
            f"Database {db_path} already exists. Use overwrite=True to recreate it. Stopp building the database."
        )
        sys.exit(1)

    if db_path.exists():
        try:
            db_path.unlink()
            logger.info(f"Successfully deleted {db_path}")
        except PermissionError as e:
            logger.exception(f"Failed to delete {db_path}: {e}")
            sys.exit(1)

    logger.info("Applying the schema to the database")
    conn = sqlite3.connect(db_path)
    conn.enable_load_extension(True)
    cursor = conn.cursor()

    for script in sql_scripts:
        logger.info(f"Applying {script}")
        with open(script, "r") as f:
            cursor.executescript(f.read())

    conn.commit()
    conn.close()

    if load_test_data:
        logger.info("Loading test data from the temporary dump")
        commands = [
            [
                "ogr2ogr",
                "-append",
                "-update",
                "-nlt",
                "PROMOTE_TO_MULTI",
                db_path.as_posix(),
                "temp/dump.gpkg",
                "routes",
            ],
            [
                "ogr2ogr",
                "-append",
                "-update",
                db_path.as_posix(),
                "temp/dump.gpkg",
                "segments",
            ],
            [
                "ogr2ogr",
                "-append",
                "-update",
                db_path.as_posix(),
                "temp/dump.gpkg",
                "route_segments",
            ],
        ]

        for command in commands:
            logger.info(f"Executing command: {' '.join(command)}")
            try:
                cmd = subprocess.run(command, check=True, capture_output=True)
            except subprocess.CalledProcessError as e:
                logger.error(f"Command failed: {e}")
                sys.exit(1)

    logger.info(f"Successfully created {db_path}")


LOGGING_CONFIG = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "simple": {"format": "%(asctime)s - %(levelname)s - %(message)s"},
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
