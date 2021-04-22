#! /bin/bash
APP_VERSION=$(grep "version" ./package.json | awk -F '"' '{ print $4 }')
HOME_DIR=$(pwd)

# Default docker image name 
DOCKER_IMG="stellara-frontend"
 
# Default app source
PUBLIC_PATH="app"

if [ "$1" == "dev" ]; then
  APP_VERSION=dev
fi

if [ "$1" == "latest" ]; then
  APP_VERSION=latest
fi

# Splash info
echo "--------------------------------------------------------------------"
echo "Image name: ${DOCKER_IMG}"
echo "App version: ${APP_VERSION}"
echo "--------------------------------------------------------------------"
 
# Auto build 
while true
do
  read -p "Proceed?(y/n)" response

  case $response in
   [yY]* )
      if [ ! -d ./dist ]; then
        mkdir ${HOME_DIR}/dist
      fi
      rm -rf ${HOME_DIR}/dist/*
      quasar build
      if [[ "${PUBLIC_PATH}" != "/" && "${PUBLIC_PATH}" != "" ]]; then
        cd ${HOME_DIR}/dist/
        mkdir ${PUBLIC_PATH}
        mv ./spa ./${PUBLIC_PATH}
        mv ${PUBLIC_PATH} ./spa
        cd ./spa
        mv spa ${PUBLIC_PATH}
      fi
      cd ${HOME_DIR}
      docker build -t ${DOCKER_IMG}:${APP_VERSION} .
      break;;

   [nN]* ) exit;;
 
   * )     echo "Oh no, please try again!"; break ;;
  esac
done
 
exit 0