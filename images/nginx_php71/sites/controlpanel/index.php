<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Control Panel Vhost</title>
</head>
<body>
    <h1>Control Panel for Kaliop Docker platform</h1>

    <h2>eZPublish web server</h2>
    <ul>
        <li><a href="/phpinfo.php">PHP Info</a></li>
        <li><a href="/ocp.php">PHP Opcache Info</a></li>
        <li><a href="/server-status">Apache Server Status</a></li>
        <li><a href="/server-info">Apache Server Info</a></li>
    </ul>

    <h2>Other servers</h2>
    <ul>
        <li><a href="/memcache/">Memcached Info</a></li>
        <li><a href="http://admin:pass@localhost:88/phpmemadmin/web/index.php">Memcached Admin</a></li>
        <li><a href="http://<?php echo $_SERVER['SERVER_NAME']; ?>:8983/solr/">Solr</a></li>
        <li><a href="/pma/index.php">PhpMyAdmin</a></li>
        <li><a href="http://varnish:CacheMeIfYouCan@localhost:88/va/html/">Varnish</a></li>
    </ul>

    <p>Login & password for Varnish & Memcached Admin are already present in the above links.</p>
    <p>If needed, here are the credentials: </p>
    <ul>
        <li>Varnish : varnish / CacheMeIfYouCan</li>
        <li>Memcached Admin : admin / pass</li>
    </ul>
</body>
</html>
