#!/bin/bash
echo "Container Started"
export PYTHONUNBUFFERED=1

echo "source /workspace/venv/bin/activate" >> ~/.bashrc
source ~/.bashrc

# Workaround for:
#   https://github.com/TimDettmers/bitsandbytes/issues/62
#   https://github.com/TimDettmers/bitsandbytes/issues/73
pip install bitsandbytes==0.37.0

cd /workspace/EveryDream2trainer
git fetch && git pull
mkdir -p /workspace/EveryDream2trainer/logs
mkdir -p /workspace/EveryDream2trainer/input

# RunPod SSH
if [[ -v "PUBLIC_KEY" ]] && [[ ! -d "${HOME}/.ssh" ]]; then
    pushd $HOME
    mkdir -p .ssh
    echo ${PUBLIC_KEY} > .ssh/authorized_keys
    chmod -R 700 .ssh
    popd
    service ssh start
fi

# RunPod JupyterLab
if [[ $JUPYTER_PASSWORD ]]
then
    cd /
    tensorboard --logdir /workspace/EveryDream2trainer/logs --host 0.0.0.0 &
    jupyter nbextension enable --py widgetsnbextension
    jupyter lab --allow-root --no-browser --port=8888 --ip=* --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' --ServerApp.token=$JUPYTER_PASSWORD --ServerApp.allow_origin=* --ServerApp.preferred_dir=/workspace/EveryDream2trainer
else
    sleep infinity
fi
