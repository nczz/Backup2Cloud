# Backup2Cloud

新版本備份工具，使用 [rclone](https://github.com/ncw/rclone) 來處理備份雲端的部分。備份邏輯與前一版本 [VPSBackupToS3](https://github.com/nczz/VPSBackupToS3) 最大的差異就是抽離備份目的地設定，和 `s3cmd` 工具解構與使用純 `bash` script 改寫。

### 相依套件

- rclone
- MySQL Client command line tools

### 使用方法

1. 安裝 rclone

	```bash
	curl https://rclone.org/install.sh | sudo bash
	```

2. 複製本專案至備份裝置，設定各項設定檔案

	- `Backup2Cloud.sh` 設定備份天數、備份網站與資料庫資訊、異地備份位置（以 [AWS S3](https://rclone.org/s3/) 為例）。
	- `db_ignore.txt` 設定不要備份的資料庫，一行一個。
	- `www_ignore.txt` 設定不要備份的網站目錄，一行一個。

3. 加入 crontab 每天凌晨進行備份

	```bash
	crontab -e
	# chmod +x Backup2Cloud.sh
	# 0 2 * * * /bin/bash /path/to/Backup2Cloud.sh > /path/to/backup.log 
	```

### 授權

> MIT License 
