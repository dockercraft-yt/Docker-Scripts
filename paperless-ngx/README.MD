## Information:
Es muss im Container das Backup Verzeichnis als Volume gemounted werden.

Dies ist eine Beispiel compose.yaml wo das Backup Verzeichnis gemounted ist.
```yaml
    services:
      paperless-ngx:
        container_name: paperless-ngx
        environment:
          - TZ=Europe/Berlin
          - PAPERLESS_REDIS=redis://default:redis@192.168.178.2:6379
          - PAPERLESS_OCR_LANGUAGE=deu
          - PAPERLESS_OCR_LANGUAGES=deu
          - PAPERLESS_FILENAME_FORMAT={{ created_year }}/{{ created_month }}/{{
            added_year }}{{ added_month }}{{ added_day }}-{{ title }}
          - PAPERLESS_TIME_ZONE=Europe/Berlin
          - PAPERLESS_CONSUMER_ENABLE_ASN_BARCODE=true
          - PAPERLESS_CONSUMER_ASN_BARCODE_PREFIX=ASN
          - PAPERLESS_CONSUMER_ENABLE_BARCODES=true
          - PAPERLESS_CONSUMER_BARCODE_SCANNER=ZXING
          - PAPERLESS_CONSUMER_BARCODE_STRING=PATCHT
          - PAPERLESS_ENABLE_HTTP_REMOTE_USER=true
          - PAPERLESS_IGNORE_DATES=
          - PAPERLESS_CONSUMER_POLLING=120
          - PAPERLESS_SECRET_KEY=KEY
          - USERMAP_UID=99
          - USERMAP_GID=100
        ports:
          - 27030:8000/tcp
        volumes:
          - /mnt/user/appdata/paperless-ngx/data:/usr/src/paperless/data
          - /mnt/user/paperless/media/:/usr/src/paperless/media
          - /mnt/user/paperless/consume/:/usr/src/paperless/consume
          - /mnt/user/paperless/export/:/usr/src/paperless/export
          - /mnt/user/Backup/paperless:/usr/src/paperless/backup
          - /mnt/user/paperless/custom_scripts:/custom-cont-init.d:ro
          - /mnt/user/paperless/consume_script:/usr/src/paperless/scripts
        image: ghcr.io/paperless-ngx/paperless-ngx
```