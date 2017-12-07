#!/bin/bash

SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)

STRING='put your unique phrase here'

sudo printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /tmp/wordpress/wp-config.php

sudo sed -i "s/database_name_here/wordpress/"  /tmp/wordpress/wp-config.php

sudo sed -i "s/username_here/wordpressuser/"       /tmp/wordpress/wp-config.php

sudo sed -i "s/password_here/password/"   /tmp/wordpress/wp-config.php

sudo sed -i "s/wp_/wnotp_/"               /tmp/wordpress/wp-config.php

