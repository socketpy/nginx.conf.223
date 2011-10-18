# -*- mode: nginx; mode: flyspell-prog; mode: autopair; ispell-current-dictionary: american -*-
### Configuration for example.com.


## HTTP server.
server {
    listen 80;
    # 因为很多老的静态网站链接到www.fltrp.com/download/目录下的资源
    # 为了不去修改那些静态文件。我们采取让nginx重定向那些目录到 old.fltrp.com/download的方式
    server_name www.fltrp.com;
    #limit_conn arbeit 16;

    ## Access and error logs.
    #access_log  logs/access.log;
    #error_log   logs/error.log;

    ## Include the blacklist.conf file.
    #include sites-available/blacklist.conf;

    ## Disable all methods besides HEAD, GET and POST.
    #if ($request_method !~ ^(GET|HEAD|POST)$ ) {
        #return 444;
    #}

    root  /var/www/d7production/;
    index index.php index.html;

    ## Include all Drupal stuff.
    #include sites-available/drupal.conf;

    ## For D7. Use this instead.
    include sites-available/drupal7.conf;
    #include sites-available/d7apache.conf;
    #include sites-available/d7wzsy.conf;
    

    proxy_connect_timeout 600s;
    proxy_send_timeout 600s;
    proxy_read_timeout 600s; 


    ## For upload progress to work. From the README of the
    ## filefield_nginx_progress module.
    #location ~ (.*)/x-progress-id:(\w*) {
        #rewrite ^(.*)/x-progress-id:(\w*)  $1?X-Progress-ID=$2;
    #}

    #location ^~ /progress {
        #report_uploads uploads;
    #}
    
    # 在这里我重新定向 
    # 参考： http://wiki.nginx.org/Pitfalls
    location ^~ /download {
	rewrite ^ $scheme://old.fltrp.com$request_uri permanent;
	}	

} # HTTP server