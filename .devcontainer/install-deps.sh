env
echo `pwd`

# Ruby requirements. Why won't mise install these for me?
sudo apt update && sudo apt install -y zlib1g-dev libssl-dev libffi-dev libyaml-dev

curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
mise install