#!/usr/bin/env bash

cat >/lib/systemd/system/mountwg.service <<EOF
[Unit]
Description=A virtual file system adapter for Azure Blob storage.
After=network.target

[Service]
Environment=BlobCfg=/etc/connection.cfg
# Configures the mountpoint.
Environment=BlobMountingPoint=/etc/wireguard
# Configures the tmp location for the cache. Always configure the fastest disk (SSD or ramdisk) for best performance.
Environment=BlobTmp=/mnt/blobfusetmp/wireguard
# Sets the name of the container in the storage account.
Environment=ContainerName=wireguard

# Enables HTTPS communication with Blob storage. True by default. HTTPS must be if you are communicating to the Storage Container through OAuth.
Environment=BlobUseHttps=true
# Blobs will be cached in the temp folder for this many seconds. 120 seconds by default. During this time, blobfuse will not check whether the file is up to date or not.
Environment=BlobFileCacheTimeOutInSeconds=120
# Enables logs written to syslog. Set to LOG_WARNING by default. Allowed values are LOG_OFF|LOG_CRIT|LOG_ERR|LOG_WARNING|LOG_INFO|LOG_DEBUG
Environment=BlobLogLevel=LOG_WARNING
# Enables attributes of a blob being cached. False by default. (Only available in blobfuse 1.1.0 or above)
Environment=BlobUseAttrCache=false

Environment=attr_timeout=240
Environment=entry_timeout=240
Environment=negative_timeout=120
Type=forking

ExecStart=/usr/bin/blobfuse \${BlobMountingPoint} --container-name=\${ContainerName} --tmp-path=\${BlobTmp} --config-file=\${BlobCfg} --use-https=\${BlobUseHttps} --file-cache-timeout-in-seconds=\${BlobFileCacheTimeOutInSeconds} --log-level=\${BlobLogLevel} --use-attr-cache=\${BlobUseAttrCache} -o attr_timeout=\${attr_timeout} -o entry_timeout=\${entry_timeout} -o negative_timeout=\${negative_timeout}
ExecStop=/usr/bin/fusermount -u \${BlobMountingPoint}

[Install]
WantedBy=multi-user.target
EOF