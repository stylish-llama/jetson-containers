#!/usr/bin/env bash
set -ex
echo "Building torchaudio ${TORCHAUDIO_VERSION}"
   
apt-get update
apt-get install -y --no-install-recommends \
		git \
		pkg-config \
		libffi-dev \
		libsndfile1

rm -rf /var/lib/apt/lists/*
apt-get clean

git clone --branch=v${TORCHAUDIO_VERSION} --recursive --depth=1 https://github.com/pytorch/audio /opt/torchaudio ||
git clone --branch=release/${BRANCH_VERSION} --recursive --depth=1 https://github.com/pytorch/audio /opt/torchaudio ||
git clone --recursive --depth=1 https://github.com/pytorch/audio /opt/torchaudio
cd /opt/torchaudio

# https://github.com/pytorch/audio/pull/3811
sed -i '1i#include <float.h>' src/libtorchaudio/cuctc/src/ctc_prefix_decoder_kernel_v2.cu || echo "warning:  failed to patch ctc_prefix_decoder_kernel_v2.cu"

BUILD_VERSION=${TORCHAUDIO_VERSION} \
BUILD_SOX=1 \
python3 setup.py bdist_wheel --verbose --dist-dir /opt

cd ../
rm -rf /opt/torchaudio

pip3 install /opt/torchaudio*.whl
pip3 show torchaudio && python3 -c 'import torchaudio; print(torchaudio.__version__);'

twine upload --verbose /opt/torchaudio*.whl || echo "failed to upload wheel to ${TWINE_REPOSITORY_URL}"
