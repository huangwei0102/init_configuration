#! /bin/bash
# https://github.com/huangwei0102/init_configuration/blob/main/etc/bootstrap.sh
set -e
set -x

export DEBIAN_FRONTEND=noninteractive

mkdir -p ~/.ssh
chmod 700 ~/.ssh
cd ~/.ssh

#MSI
PUB_KEY1="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJ7vNox06KpbNbdzlO8j3u4IfjsAvNKkeOWE9GSvhhsbPE5P1lhBALUkT4G8b5jZawR/7BsTiAzIUJghaBkPMy7RuGHKE3kMIeWhMcarjdEyT1hSTv68pmGEALHHwqFwgTKWEkvFCid5OHLUVnhenReRFglP8/X8ucIEN3JwyzS2ZrOGrVlXXrAbirV7GtkSOHQg1G5vObesizwz0L0JeyHnEFASv2wDnqCcZs3w9ymyuPmYV5qEFwx1/+50aVDrI+GSG/sErv/H9bJ2PdT96/UXcIVEe8CKz59PNIQEc4HUm5oxQ9nYkYOm7HgRnM6FJSCszU66RyCwz4z+SKQjTHzo0eeXBaMgxREJVqCGTrcENPfnBHpoMjdr7SRKmDd2HbvuKme/tsWCFJsXaZH+/qoCiaL9HAKO8bcOeqofZIct/FinCg4ZuU1BIvi1QCuHjNqv/PxbGkYDMxpGdNGlcAYTxvmFs9CXDq568NWSGMeYz7xSUH3p3Q0Tf0T+KztyTjRU+IDHoZEi4MPAx3cel8/8hPWODiCjFBUTC4mGbkihGWKv9uJODSg+2CnXkMPwzR7FpD90Kb/NlYj4UGMHjKTzUkUYItAxQEJixH6r+TXbw/i4QjnBbfGtG/tC3JWF26Zh23au/ALlp5UqMLWCJBGCM4kwiq+Gd4ZjIdyKHxNQ== 569446624@qq.com"

# Combine the public keys into an array
PUB_KEYS=("$PUB_KEY1")

# Loop through each public key in the array
for PUB_KEY in "${PUB_KEYS[@]}"; do
    # Check if the public key already exists in authorized_keys
    if grep -qF "$PUB_KEY" authorized_keys; then
        echo "Public key already exists in authorized_keys."
    else
        # If the public key does not exist, append it to authorized_keys
        echo "$PUB_KEY" >> authorized_keys
        echo "Public key added to authorized_keys."
    fi
done

# Ensure authorized_keys file has the correct permissions
chmod 600 authorized_keys


mkdir -p ~/.local/init
cd ~/.local/init

git clone https://github.com/huangwei0102/init_configuration.git
cd ~/.local/init/init_configuration/etc
bash update.sh

echo 'source ~/.local/etc/init.sh' >> ~/.bashrc
echo 'umask 022' >> ~/.bashrc

