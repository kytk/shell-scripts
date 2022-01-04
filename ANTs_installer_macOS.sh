#!/bin/bash
# A script to compile ANTs for macOS
# K. Nemoto 4 Jan 2022


# Check OS
os=$(uname)

if [ $os != "Darwin" ]; then
  echo "This script is for macOS only."
  echo "exit"
  exit 1
fi


# xcode-select
echo "Check if xcode-select is installed"
chk_xcodeselect=$(basename $(which xcode-select))
if [ ${chk_xcodeselect} != "xcode-select" ]; then
  echo "   xcode-select needs to be installed"
  echo "   Please follow the dialogue"
  xcode-select --install
else
  echo "   xcode-select is installed"
fi


# Homebrew
echo "Check if Homebrew is installed"
chk_homebrew=$(basename $(which brew))
if [ "${chk_homebrew}" = "brew" ]; then
  echo "   Homebrew is installed"
else
  echo "   Homebrew is to be installed"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi


# Cmake
echo "Check if CMake is installed"
chk_cmake=$(basename $(which cmake))
if [ "${chk_cmake}" = "cmake" ]; then
  echo "   CMake is installed"
else
  echo "   CMake is to be installed"
  brew install cmake
fi


# Prepare working directory under $HOME
echo "Prepare ANTS directory under $HOME"
echo "If ANTS exists, rename to ANTS_prev"

cd $HOME

if [ -d ANTS ]; then
  mv ANTS ANTS_prev
fi

mkdir -p ANTS/{build,install}
cd ANTS
echo "Compiled on $(date +%Y-%m-%d)" > README
workingDir=${PWD}

# Compile and install ANTs
git clone https://github.com/ANTsX/ANTs.git

cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=${workingDir}/install \
    ../ANTs 2>&1 | tee cmake.log
make -j 4 2>&1 | tee build.log

cd ANTS-build
make install 2>&1 | tee install.log


# PATH setting
your_shell=$(echo $SHELL)
if  [ ${your_shell} == '/bin/bash' ]; then
  profile='~/.bash_profile'
elif  [ ${your_shell} == '/bin/zsh' ]; then
  profile='~/.zprofile'
fi

grep '$HOME/ANTS/install/bin' ${profile} > /dev/null
if [ $? -eq 1 ]; then
  echo "" >> ${profile}
  echo "#ANTs" >> ${profile}
  echo 'export ANTSPATH=$HOME/ANTS/install/bin' >> ${profile} 
  echo 'export PATH=$PATH:$ANTSPATH' >> ${profile}
fi

echo "ANTs is installed"
echo "Please close and re-run the terminal to reflect PATH setting"

