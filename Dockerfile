FROM andrius/crystal-lang:asterisk-16

COPY ./spec/asterisk_configs/*.conf /etc/asterisk/

WORKDIR /src

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bash"]
