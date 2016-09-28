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
    </ul>

    <h2>Other servers</h2>
    <ul>
        <li><a href="/memcache/">Memcached Info</a></li>
        <li><a href="/phpmemadmin/web/index.php">Memcached Admin</a></li>
        <li><a href="http://<?php echo $_SERVER['SERVER_NAME']; ?>:8983/solr/">Solr</a></li>
        <li><a href="/pma/index.php">PhpMyAdmin</a></li>
        <li><a href="/va/html/">Varnish</a></li>
    </ul>

    <p>credentials for Varnish: varnish / CacheMeIfYouCan</p>
    <p>credentials for Memcached Admin: admin / pass</p>

</body>
</html>
