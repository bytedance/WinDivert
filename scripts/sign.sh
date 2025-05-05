# This script is used to sign the driver
# See also: <https://learn.microsoft.com/en-us/windows-hardware/drivers/dashboard/code-signing-attestation>

cwd=$(pwd)
if [ -f "$cwd/.env" ]; then
  source $cwd/.env
fi

if [ -z "$BD_CERT_SERVICE_URL" ] || [ -z "$BD_CERT_SERVICE_CERT_ID" ] || [ -z "$BD_CERT_SERVICE_ACCESS_TOKEN" ]; then
  echo "Please set BD_CERT_SERVICE_URL, BD_CERT_SERVICE_CERT_ID, and BD_CERT_SERVICE_ACCESS_TOKEN in .env file."
  exit 1
fi

cd $(dirname $0)
dir=$(pwd)
install_dir="$dir/../install"

MakeCab -V3 -F $dir/WinDivert.ddf -D DiskDirectoryTemplate="$install_dir" -D SourceDir="$install_dir"
rm -f setup.rpt setup.inf

./SignTool.exe sign -fd sha256 \
  -bcsu $BD_CERT_SERVICE_URL \
  -bcsci "$BD_CERT_SERVICE_CERT_ID" \
  -bcsat "$BD_CERT_SERVICE_ACCESS_TOKEN" \
  -tr "http://timestamp.digicert.com" \
  $install_dir/WinDivert.cab
