# Reece Benson - 2019
# Automatically deploy a dev, staging and live environment structure setup for NGINX
# Follows the site structure of /var/sites/{live,staging,development}/{sitename}/{public,logs}
# Follows the NGINX structure of /etc/sites/{live,staging,development}/{live,stg,dev}.{sitename}
SITE_ROOT=/var/sites

echo "Please enter the site name:"
read SITE_NAME

echo "Please enter the site URL:"
read SITE_URL

cd $SITE_ROOT

# Make the development, staging and live structure
mkdir development/$SITE_NAME development/$SITE_NAME/logs development/$SITE_NAME/public
mkdir staging/$SITE_NAME staging/$SITE_NAME/logs staging/$SITE_NAME/public
mkdir live/$SITE_NAME live/$SITE_NAME/logs live/$SITE_NAME/public
echo "Created $SITE_NAME development, staging and live structures."

# Create the site default files
cd $SITE_ROOT/.deploy/
if [ -d "default_files" ]; then
  cp ./default_files/* ../development/$SITE_NAME/public
  cp ./default_files/* ../staging/$SITE_NAME/public
  cp ./default_files/* ../live/$SITE_NAME/public

  # Edit the default files -- there is probably a nicer way to do this...
  cd $SITE_ROOT/development/$SITE_NAME/public
  find . -name "*.php" -exec sed -i -e "s/SITENAME/$SITE_NAME/g" {} \;
  find . -name "*.php" -exec sed -i -e "s/SITEURL/$SITE_URL/g" {} \;

  cd $SITE_ROOT/staging/$SITE_NAME/public
  find . -name "*.php" -exec sed -i -e "s/SITENAME/$SITE_NAME/g" {} \;
  find . -name "*.php" -exec sed -i -e "s/SITEURL/$SITE_URL/g" {} \;

  cd $SITE_ROOT/live/$SITE_NAME/public
  find . -name "*.php" -exec sed -i -e "s/SITENAME/$SITE_NAME/g" {} \;
  find . -name "*.php" -exec sed -i -e "s/SITEURL/$SITE_URL/g" {} \;
fi

# Create the NGINX Site
cd $SITE_ROOT/.deploy/
mkdir $SITE_NAME
cp nginxsite $SITE_NAME/dev.$SITE_NAME
cp nginxsite $SITE_NAME/stg.$SITE_NAME
cp nginxsite $SITE_NAME/live.$SITE_NAME
cd $SITE_NAME

# Edit the files
find . -name "*.$SITE_NAME" -exec sed -i -e "s/SITENAME/$SITE_NAME/g" {} \;
find . -name "dev.$SITE_NAME" -exec sed -i -e "s/SITEURL/dev.$SITE_URL/g" {} \;
find . -name "stg.$SITE_NAME" -exec sed -i -e "s/SITEURL/stg.$SITE_URL/g" {} \;
find . -name "live.$SITE_NAME" -exec sed -i -e "s/SITEURL/$SITE_URL/g" {} \;
find . -name "dev.$SITE_NAME" -exec sed -i -e "s/SITETYPE/development/g" {} \;
find . -name "stg.$SITE_NAME" -exec sed -i -e "s/SITETYPE/staging/g" {} \;
find . -name "live.$SITE_NAME" -exec sed -i -e "s/SITETYPE/live/g" {} \;

# Move the files
mv dev.$SITE_NAME /etc/sites/development
mv stg.$SITE_NAME /etc/sites/staging
mv live.$SITE_NAME /etc/sites/live

# Cleanup
cd ../
rm -d $SITE_NAME
echo "Cleaned up NGINX temporary directory"

echo "Created $SITE_NAME NGINX configuration files, restarting nginx (requires privileges)..."
sudo service nginx restart
echo "...completed."
