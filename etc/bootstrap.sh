#! /bin/sh
# https://github.com/huangwei0102/init_configuration/blob/main/etc/bootstrap.sh
set -e
set -x

export DEBIAN_FRONTEND=noninteractive

mkdir -p ~/.ssh
chmod 700 ~/.ssh
cd ~/.ssh
# MSI: ssh-keygen -t rsa -b 4096 -C "
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJ7vNox06KpbNbdzlO8j3u4IfjsAvNKkeOWE9GSvhhsbPE5P1lhBALUkT4G8b5jZawR/7BsTiAzIUJghaBkPMy7RuGHKE3kMIeWhMcarjdEyT1hSTv68pmGEALHHwqFwgTKWEkvFCid5OHLUVnhenReRFglP8/X8ucIEN3JwyzS2ZrOGrVlXXrAbirV7GtkSOHQg1G5vObesizwz0L0JeyHnEFASv2wDnqCcZs3w9ymyuPmYV5qEFwx1/+50aVDrI+GSG/sErv/H9bJ2PdT96/UXcIVEe8CKz59PNIQEc4HUm5oxQ9nYkYOm7HgRnM6FJSCszU66RyCwz4z+SKQjTHzo0eeXBaMgxREJVqCGTrcENPfnBHpoMjdr7SRKmDd2HbvuKme/tsWCFJsXaZH+/qoCiaL9HAKO8bcOeqofZIct/FinCg4ZuU1BIvi1QCuHjNqv/PxbGkYDMxpGdNGlcAYTxvmFs9CXDq568NWSGMeYz7xSUH3p3Q0Tf0T+KztyTjRU+IDHoZEi4MPAx3cel8/8hPWODiCjFBUTC4mGbkihGWKv9uJODSg+2CnXkMPwzR7FpD90Kb/NlYj4UGMHjKTzUkUYItAxQEJixH6r+TXbw/i4QjnBbfGtG/tC3JWF26Zh23au/ALlp5UqMLWCJBGCM4kwiq+Gd4ZjIdyKHxNQ== 569446624@qq.com" >> authorized_keys
chmod 600 authorized_keys

mkdir -p ~/.local/init
cd ~/.local/init

git clone git@github.com:huangwei0102/init_configuration.git
cd ~/.local/init/init_configuration
sh update.sh

echo 'source ~/.local/etc/init.sh' >> ~/.bashrc
echo 'umask 022' >> ~/.bashrc

