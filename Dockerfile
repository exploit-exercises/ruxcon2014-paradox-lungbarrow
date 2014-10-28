FROM fedora:latest
RUN yum upgrade -y || true
RUN yum groupinstall -y "C Development Tools and Libraries"
RUN yum install -y rubygem-bundler libsqlite3x-devel ruby-devel make patch automake autoconf 
RUN yum install -y vim-common nano
WORKDIR /app
ADD . /app
RUN bundle install --path /app/vendor 
USER 9998:9998
EXPOSE 9998
CMD [ "bundle", "exec", "ruby", "lungbarrow.rb", "-p", "9998", "-o", "0.0.0.0", "-e", "production" ]
