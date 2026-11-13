function platform () {
    command -v docker-compose >/dev/null 2>&1 || {
        echo -e "${ROUGE}Require Docker but it's not installed.  Aborting.${GRIS}";
        echo -e "${ROUGE}      * debian : apt-get install docker${GRIS}";
        echo -e "${ROUGE}      * macosx : brew install docker${GRIS}";
        echo -e "${ROUGE}      * redhat : yum -y install docker${GRIS}";
        exit 1;
    }
    # please change for you own mood
    CURRENTDIR=$(pwd);
    USERNAME="elias";
    PLATFORM=""
    STATUS=""
    PROJECT=""
    ENVIRONNEMENT=""
    KILL_DOCKER="false"
    while [[ $# -gt 0 ]]
    do
        key="$1"
        # echo ${key}
        case $key in
            --platforms)
                echo -e "${VERT}[platform] list of platforms: ${PLATFORM}${GRIS}";
                echo -e "${JAUNE}     - apiserver dependencies: ${GRIS}apiserver,backend,theagent-api-server,theagend-backend";
                echo -e "${JAUNE}     - pim dependencies: ${GRIS}pim,dashboard,theagent-vue-dashboard,theagend-node-pim";
                echo -e "${JAUNE}     - standard dependencies: ${GRIS}standard,theagend-node-standard";
                echo -e "${JAUNE}     - shopify dependencies: ${GRIS}shopify,theagend-node-shopify";
                echo -e "${JAUNE}     - reporting dependencies: ${GRIS}reporting,theagend-node-reporting,reporting-with-edi,theagend-node-reporting-with-edi";
                echo -e "${JAUNE}     - healthcheck dependencies: ${GRIS}healthcheck,healthcheck-node-reporting";
                echo -e "${JAUNE}     - edi dependencies: ${GRIS}edi,edi-with-ftp,theagend-node-edi,theagend-node-edi-with-ftp,edi-with-reporting,theagend-node-edi-with-reporting";
                echo -e "${JAUNE}     - frontend dependencies: ${GRIS}apiserver,theagend-frontend";
                echo -e "${JAUNE}     - mysql";
                echo -e "${JAUNE}     - pricemanager dependencies: ${GRIS}pricemanager,theagent-node-pricemanager";
                echo -e "${VERT}[gedan] list of platforms: ${PLATFORM}${GRIS}";
                echo -e "${JAUNE}     - vod dependencies: ${GRIS}vod";
                echo -e "${JAUNE}     - nlp dependencies: ${GRIS}nlp";
                echo -e "${JAUNE}     - base dependencies: ${GRIS}base";
                echo -e "${JAUNE}     - mysql";
                echo -e "${BLEU}[platform] OK${GRIS}";
                return;
            ;;
            -e|--env)
                ENVIRONNEMENT="$2"
                echo -e "${VERT}[platform] Platform setted: ${ENVIRONNEMENT}${GRIS}";
                shift # past argument
            ;;
            -p|--platform)
                echo -e "${VERT}[platform] Platform setted: ${PLATFORM}${GRIS}";
                PLATFORM="$2"
                shift # past argument
            ;;
            --projects)
                echo -e "${VERT}[platform] list of projects: ${PLATFORM}${GRIS}";
                echo -e "${JAUNE}     - pimtheagent ${GRIS}";
                echo -e "${JAUNE}     - dashboardtheagent ${GRIS}";
                echo -e "${JAUNE}     - stockdashboardtheagent ${GRIS}";
                echo -e "${JAUNE}     - oauthdashboardtheagent ${GRIS}";
                echo -e "${JAUNE}     - saurondashboardtheagent ${GRIS}";
                echo -e "${BLEU}[platform] OK${GRIS}";
                return;
            ;;
            --project)
                echo -e "${VERT}[platform] Project setted: ${2}${GRIS}";
                PROJECT="$2"
                shift # past argument
            ;;
            --status)
                echo -e "${VERT}[platform] Project status setted: ${PROJECT} / ${2}${GRIS}";
                STATUS="$2"
                shift # past argument
            ;;
            --kill)
                echo -e "${ROUGE}[platform] Kill all server and dependencies${GRIS}";
                KILL_DOCKER="true"
            ;;
            *) ;;
        esac
        shift # past argument or value
    done


    case $ENVIRONNEMENT in
        theagent)
            PROJECTSDIR="/home/${USERNAME}/Projets/theagent-docker-microservice";
        ;;
        *)
            echo -e "${ROUGE}[platform] environnement not setted. Please choose one theagent, ${GRIS}"
            cd ${CURRENTDIR}
            exit 1;
        ;;
    esac
    # go to projects directories
    echo -e "${BLEU}[${ENVIRONNEMENT}] Go to ${PROJECTSDIR}${GRIS}";
    cd ${PROJECTSDIR}

    if [ -n "$PROJECT" ]; then
        if [[ "$STATUS" == "start" ]]; then
            echo -e "${VERT}[platform] Load project : ${PROJECT}${GRIS}";
            case $PROJECT in
                'pimtheagent')
                    docker exec -it pimtheagent /bin/bash -c 'WEB=true LOG_LEVEL=debug node_modules/.bin/nodemon -- --config'
                ;;
                'stockdashboardtheagent'|'oauthdashboardtheagent'|'dashboardtheagent'|'saurondashboardtheagent')
                    docker exec -it $PROJECT /bin/bash -c 'npm run serve'
                ;;
                *) echo -e "${ROUGE}[platform] project invalid${GRIS}" ;;
            esac
        else
             echo -e "${ROUGE}[platform] No project setted${GRIS}"
        fi

        cd ${CURRENTDIR}
        echo -e "${BLEU}[platform][${ENVIRONNEMENT}] OK${GRIS}";
    else
        if [[ "$KILL_DOCKER" == "true" ]]; then
            docker.exe stop $(docker ps -aq);
        fi

        case $PLATFORM in
            'apiserver'|'backend'|'theagent-api-server'|'theagend-backend')
                # load apiserver services
                echo -e "${VERT}[platform] Load apiserver services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d mysqltheagent myadmintheagent nginxtheagent apitheagent backendtheagent
            ;;
            'apisansmysql')
                # load apiserver services
                echo -e "${VERT}[platform] Load apiserver services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d nginxtheagent apitheagent backendtheagent
            ;;
            'prestashop'|'prestashoptheagent')
                # load apiserver services
                echo -e "${VERT}[platform] Load prestashop services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d mysqltheagent myadmintheagent nginxtheagent editheagent prestashoptheagent
            ;;
            'pim'|'dashboard'|'theagent-vue-dashboard'|'theagend-node-pim')
                # load pim services
                echo -e "${VERT}[platform] Load pim services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d pimtheagent mysqltheagent myadmintheagent nginxtheagent dashboardtheagent
            ;;
            'standard'|'theagend-node-standard')
                # load standard services
                echo -e "${VERT}[platform] Load standard services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d standardtheagent mysqltheagent myadmintheagent nginxtheagent apitheagent
            ;;
            'shopify'|'theagend-node-shopify')
                # load shopify services
                echo -e "${VERT}[platform] Load shpify services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d shopifytheagent mysqltheagent myadmintheagent nginxtheagent
            ;;
            'woo'|'woocommerce'|'theagend-node-woocommerce')
                # load woocommerce services
                echo -e "${VERT}[theagent] Load shpify services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d woocommercetheagent editheagent mysqltheagent myadmintheagent nginxtheagent
            ;;
            'reporting'|'theagend-node-reporting'|'reporting-with-edi'|'theagend-node-reporting-with-edi')
                # load reporting services
                echo -e "${VERT}[theagent] Load shpify services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                SUB="with-edi"
                if [[ "$PLATFORM" == *"$SUB"* ]]; then
                    echo -e "${VERT}[platform] Load edi services with ftp${GRIS}";
                    docker-compose -f docker-compose.yml up -d reportingtheagent editheagent mysqltheagent myadmintheagent nginxtheagent
                else
                    echo -e "${VERT}[platform] Load edi services${GRIS}";
                    docker-compose -f docker-compose.yml up -d reportingtheagent mysqltheagent myadmintheagent nginxtheagent
                fi
            ;;
            'healthcheck'|'theagend-node-healthcheck')
                # load healthcheck services
                echo -e "${VERT}[theagent] Load healthcheck services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d healthchecktheagent mysqltheagent myadmintheagent nginxtheagent
            ;;
            'finance'|'theagend-node-finance'|'theagent-vue-finance')
                # load finance services
                echo -e "${VERT}[theagent] Load finance services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d financetheagent mysqltheagent myadmintheagent nginxtheagent dashboardfinancetheagent
            ;;
            'edi'|'edi-with-ftp'|'theagend-node-edi'|'theagend-node-edi-with-ftp'|'edi-with-reporting'|'theagend-node-edi-with-reporting')
                # load edi services
                docker-compose stop >/dev/null 2>&1 
                SUB="with-ftp"
                SUB2="with-reporting"
                if [[ "$PLATFORM" == *"$SUB"* ]]; then
                    echo -e "${VERT}[platform] Load edi services with ftp${GRIS}";‡
                    docker-compose -f docker-compose.yml up -d editheagent mysqltheagent nginxtheagent ftpdtheagent
                elif [[ "$PLATFORM" == *"$SUB2"* ]]; then
                    docker-compose -f docker-compose.yml up -d editheagent reportingtheagent mysqltheagent nginxtheagent
                else
                    echo -e "${VERT}[platform] Load edi services${GRIS}";
                    docker-compose -f docker-compose.yml up -d editheagent mysqltheagent nginxtheagent
                fi
            ;;
            'oauth'|'theagend-node-oauth')
                # load oauth services
                echo -e "${VERT}[theagent] Load oauth services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d oauthdashboardtheagent oauththeagent mysqltheagent nginxtheagent
            ;;
            'mysql')
                # load edi services
                echo -e "${VERT}[platform] Load edi services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml mysqltheagent
            ;;
            'natural')
                # load edi services
                echo -e "${VERT}[platform] Load edi services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml  -f docker-compose.nlp.yml up -d nlptheagent nginxtheagent
            ;;
            'vod'|'gedan-node-vod')
                # load vod services
                echo -e "${VERT}[gedan] Load vod services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml -f docker-compose.vod.yml up -d vodgedan mysqlgedan nginxgedan
            ;;
            'nlp'|'gedan-node-nlp')
                # load nlp services
                echo -e "${VERT}[gedan] Load nlp services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml -f docker-compose.nlp.yml up -d nlpgedan nginxgedan
            ;;
            'frontend'|'theagend-frontend')
                # load reporting services
                echo -e "${VERT}[theagent] Load frontend services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                # docker-compose -f docker-compose.yml -f docker-compose.frontend.yml up -d frontendtheagent apitheagent
                docker-compose -f docker-compose.yml -f docker-compose.frontend.yml up -d frontendtheagent mysqltheagent nginxtheagent apitheagent
            ;;
            'sauron'|'service'|'theagend-node-sauron')
                # load healthcheck services
                echo -e "${VERT}[theagent] Load sauron services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d saurontheagent saurondashboardtheagent mysqltheagent nginxtheagent 
            ;;
            'marketplace'|'marketplaces'|'theagend-node-marketplaces')
                # load edi services
                echo -e "${VERT}[theagent] Load marketplaces services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml  up -d marketplacetheagent mysqltheagent nginxtheagent;
            ;;
            'isengard')
                # load edi services
                echo -e "${VERT}[theagent] Load isengard services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml  up -d healthchecktheagent editheagent mappertheagent mysqltheagent nginxtheagent isengarddashboardtheagent oauththeagent oauthdashboardtheagent;
            ;;
            'home')
                # load home services
                echo -e "${VERT}[theagent] Load home services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml  up -d homedashboardtheagent hometheagent editheagent mysqltheagent nginxtheagent oauththeagent oauthdashboardtheagent;
            ;;
              'pricemanager'|'theagent-node-pricemanager')
                  # load pricemanager services
                  echo -e "${VERT}[theagent] Load pricemanager services${GRIS}";
                  docker-compose stop >/dev/null 2>&1
                  docker-compose -f docker-compose.yml up -d pricemanagertheagent mysqltheagent nginxtheagent oauththeagent myadmintheagent
              ;;
            'sam'|'theagend-node-sam')
                # load sam services
                echo -e "${VERT}[theagent] Load sam services${GRIS}";
                echo -e "${ROUGE} cette commande ne lance pas forcement le backend, check bash_aliases${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d samtheagent samdashboardtheagent cmtheagent centraletheagent healthchecktheagent mysqltheagent nginxtheagent; # avec le back
                # docker-compose -f docker-compose.yml up -d samdashboardtheagent mysqltheagent nginxtheagent;
            ;;
            'vuefront')
                # load healthcheck services
                echo -e "${VERT}[theagent] Load vuefront services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d saurondashboardtheagent oauththeagent stockdashboardtheagent oauthdashboardtheagent nginxtheagent
            ;;
            'stock'|'stockmanager')
                # load healthcheck services
                echo -e "${VERT}[theagent] Load vuefront services${GRIS}";
                echo -e "${ROUGE} cette commande ne lance pas forcement le backend, check bash_aliases${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                # docker-compose -f docker-compose.yml up -d oauththeagent stockdashboardtheagent stocktheagent oauthdashboardtheagent nginxtheagent # avec le back
                docker-compose -f docker-compose.yml up -d oauththeagent stockdashboardtheagent oauthdashboardtheagent nginxtheagent
                # docker-compose -f docker-compose.yml up -d saurontheagent saurondashboardtheagent mysqltheagent nginxtheagent 
            ;;
            'grafana')
                # load healthcheck services
                echo -e "${VERT}[theagent] Load grafana services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml  up -d grafanatheagent prometheustheagent healthchecktheagent mysqltheagent nginxtheagent
            ;;
            'mapper')
                # load pim services
                echo -e "${VERT}[theagent] Load mapper services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml  up -d mappertheagent pimtheagent mysqltheagent nginxtheagent myadmintheagent centraletheagent mapperdashboardtheagent
            ;;
            'dex')
                # load pim services
                echo -e "${VERT}[theagent] Load dex services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d dextheagent mysqltheagent nginxtheagent myadmintheagent dexdashboardtheagent
            ;;
            'oms')
                # load pim services
                echo -e "${VERT}[theagent] Load oms services${GRIS}";
                docker-compose stop >/dev/null 2>&1 
                docker-compose -f docker-compose.yml up -d marketplacetheagent editheagent mysqltheagent nginxtheagent omsdashboardtheagent
            ;;
            *)
                echo -e "${ROUGE}[platform] No platform setted${GRIS}"
            ;;
        esac
        cd ${CURRENTDIR}
        echo -e "${BLEU}[platform][${ENVIRONNEMENT}] OK${GRIS}";
    fi

}