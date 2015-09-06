Platform=`./functions.sh getPlatform $1`
APP_VERSION=`./functions.sh getAppVersion $Platform`
DOCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJ_DIR=$DOCROOT/../../
APP_MIN_VERSION=`./functions.sh getAppMinVersion $Platform`
APP_BUILD_TAG=`./functions.sh getAppBuildTag $Platform`
EXPORT_DIR=`./functions.sh getExportDir $Platform`
echo ---------------- 检查更新
cd $DOCROOT/../buildUpdate
echo "buildUpdate.py --appVersion=$APP_VERSION --minVersion=$APP_MIN_VERSION --appTag=$APP_BUILD_TAG --output=$EXPORT_DIR"
python buildUpdate.py --appVersion=$APP_VERSION --minVersion=$APP_MIN_VERSION --appTag=$APP_BUILD_TAG --output=$EXPORT_DIR
cd $DOCROOT