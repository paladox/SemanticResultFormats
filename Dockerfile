ARG MW_VERSION
ARG PHP_VERSION
FROM gesinn/mediawiki-ci:${MW_VERSION}-php${PHP_VERSION}

ARG MW_VERSION
ARG SMW_VERSION
ARG PHP_VERSION
ARG PF_VERSION
ARG SFS_VERSION
ARG MM_VERSION

# get needed dependencies for this extension
RUN sed -i s/80/8080/g /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

RUN composer-require.sh mediawiki/semantic-media-wiki ${SMW_VERSION}
RUN composer-require.sh mediawiki/page-forms ${PF_VERSION}
RUN composer-require.sh mediawiki/semantic-forms-select ${SFS_VERSION}
RUN composer-require.sh mediawiki/mermaid ${MM_VERSION}
RUN composer update 


RUN chown -R www-data:www-data /var/www/html/extensions/SemanticMediaWiki/

ENV EXTENSION=SemanticResultFormats
COPY composer*.json package*.json /var/www/html/extensions/$EXTENSION/


COPY . /var/www/html/extensions/$EXTENSION
RUN cd extensions/$EXTENSION && composer update


RUN echo \
        "wfLoadExtension( 'SemanticMediaWiki' );\n" \
        "enableSemantics( 'localhost' );\n" \
        "wfLoadExtension( 'PageForms' );\n" \
        "wfLoadExtension( 'SemanticFormsSelect' );\n" \
        "wfLoadExtension( 'Mermaid' );\n" \
        "wfLoadExtension( '$EXTENSION' );\n" \
    >> __setup_extension__