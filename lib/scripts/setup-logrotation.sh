# TODO: standardise logging to one predictable place
# TODO: include logrotation setup in Rails and PM2 projects

# To prevent log files from becoming Gigabytes big and hogging all available disk space, use logrotate.
# Best explained here:
# https://gorails.com/guides/rotating-rails-production-logs-with-logrotate

# sudo vim etc/logrotate.conf

# Then add:

# /var/www/rails.api.interflux.com/log/*.log {
#   daily
#   missingok
#   rotate 7
#   compress
#   delaycompress
#   notifempty
#   copytruncate
# }

# /home/admin/.pm2/logs/*.log {
#   daily
#   missingok
#   rotate 7
#   compress
#   delaycompress
#   notifempty
#   copytruncate
# }

# Force restart

# sudo /usr/sbin/logrotate -f /etc/logrotate.conf

# Run the same command again to see the compression.

# Check

# ls -la /var/www/rails.api.interflux.com/log/

# Should see -1 and .tar