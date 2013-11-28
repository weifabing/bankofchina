#/bin/bash
# china of bank weifabing@126.com
APP_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TODAY=$(date +%Y_%m_%d)
FILE="boc_$TODAY.txt.tar.gz"
TODAY2=$(date +%Y%m%d)
DATA_DIR="$APP_ROOT/data"
PGP_FILE="$DATA_DIR/boc_file/zdz_zuanshi_$TODAY2.txt.pgp"
ZIP_FILE="$DATA_DIR/tmp/zdz_zuanshi_$TODAY2.txt.gz"
OUT_FILE="$DATA_DIR/tmp/zdz_zuanshi_$TODAY2.txt"
BACK_DIR="$DATA_DIR/backup/"
IdentityFile="$APP_ROOT/key/***.key"

#Step 0: SFTP Down File
sftp -o IdentityFile=${IdentityFile} -o Port=988 zuanshi@10.10.10.10 -b <<EOC
cd /upload
lcd $DATA_DIR/boc_file
get zdz_zuanshi_$TODAY2.txt.pgp
exit
EOC

#Step 1: Decryption File 
if [ -f "$PGP_FILE" ]
then
    gpg --no-mdc-warning -o $ZIP_FILE -d "$PGP_DIR$PGP_FILE"
else
    echo "$PGP_FILE not find"
    exit
fi

#Step 2: unzip File
if [ -f $ZIP_FILE ]
then
   gzip -d $ZIP_FILE
else
   echo "gpg decryption Fail"
   exit
fi

if [ ! -f $OUT_FILE ]
then
   echo "unzip file  Fail"
   exit
fi

#Step 3: Send File From Email
server='smtp.163.com'
from='weifabing@163.com'
to='weifabing@126.com'
user='weifabing'
pass='********'
subject=$(echo '中国银行分期付款对账单'|iconv -f UTF-8 -t gbk)
msg=$(date +"%Y_%m_%d %H:%I:%S")
file=$OUT_FILE

$APP_ROOT/bin/mail -s $server -f $from -t $to -u $user -p $pass -S "$subject" -m "${msg}" -F $file

#Step 4: back up file
if [ ! -d $BACK_DIR ]
then
   mkdir $BACK_DIR
fi
mv $OUT_FILE $BACK_DIR
