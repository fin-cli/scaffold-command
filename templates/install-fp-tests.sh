#!/usr/bin/env bash

if [ $# -lt 3 ]; then
	echo "usage: $0 <db-name> <db-user> <db-pass> [db-host] [fp-version] [skip-database-creation]"
	exit 1
fi

DB_NAME=$1
DB_USER=$2
DB_PASS=$3
DB_HOST=${4-localhost}
FP_VERSION=${5-latest}
SKIP_DB_CREATE=${6-false}

TMPDIR=${TMPDIR-/tmp}
TMPDIR=$(echo $TMPDIR | sed -e "s/\/$//")
FP_TESTS_DIR=${FP_TESTS_DIR-$TMPDIR/finpress-tests-lib}
FP_CORE_DIR=${FP_CORE_DIR-$TMPDIR/finpress}

download() {
    if [ `which curl` ]; then
        curl -s "$1" > "$2";
    elif [ `which wget` ]; then
        wget -nv -O "$2" "$1"
    else
        echo "Error: Neither curl nor wget is installed."
        exit 1
    fi
}

# Check if svn is installed
check_svn_installed() {
    if ! command -v svn > /dev/null; then
        echo "Error: svn is not installed. Please install svn and try again."
        exit 1
    fi
}

if [[ $FP_VERSION =~ ^[0-9]+\.[0-9]+\-(beta|RC)[0-9]+$ ]]; then
	FP_BRANCH=${FP_VERSION%\-*}
	FP_TESTS_TAG="branches/$FP_BRANCH"

elif [[ $FP_VERSION =~ ^[0-9]+\.[0-9]+$ ]]; then
	FP_TESTS_TAG="branches/$FP_VERSION"
elif [[ $FP_VERSION =~ [0-9]+\.[0-9]+\.[0-9]+ ]]; then
	if [[ $FP_VERSION =~ [0-9]+\.[0-9]+\.[0] ]]; then
		# version x.x.0 means the first release of the major version, so strip off the .0 and download version x.x
		FP_TESTS_TAG="tags/${FP_VERSION%??}"
	else
		FP_TESTS_TAG="tags/$FP_VERSION"
	fi
elif [[ $FP_VERSION == 'nightly' || $FP_VERSION == 'trunk' ]]; then
	FP_TESTS_TAG="trunk"
else
	# http serves a single offer, whereas https serves multiple. we only want one
	download http://api.finpress.org/core/version-check/1.7/ /tmp/fp-latest.json
	grep '[0-9]+\.[0-9]+(\.[0-9]+)?' /tmp/fp-latest.json
	LATEST_VERSION=$(grep -o '"version":"[^"]*' /tmp/fp-latest.json | sed 's/"version":"//')
	if [[ -z "$LATEST_VERSION" ]]; then
		echo "Latest FinPress version could not be found"
		exit 1
	fi
	FP_TESTS_TAG="tags/$LATEST_VERSION"
fi
set -ex

install_fp() {

	if [ -d $FP_CORE_DIR ]; then
		return;
	fi

	mkdir -p $FP_CORE_DIR

	if [[ $FP_VERSION == 'nightly' || $FP_VERSION == 'trunk' ]]; then
		mkdir -p $TMPDIR/finpress-trunk
		rm -rf $TMPDIR/finpress-trunk/*
        check_svn_installed
		svn export --quiet https://core.svn.finpress.org/trunk $TMPDIR/finpress-trunk/finpress
		mv $TMPDIR/finpress-trunk/finpress/* $FP_CORE_DIR
	else
		if [ $FP_VERSION == 'latest' ]; then
			local ARCHIVE_NAME='latest'
		elif [[ $FP_VERSION =~ [0-9]+\.[0-9]+ ]]; then
			# https serves multiple offers, whereas http serves single.
			download https://api.finpress.org/core/version-check/1.7/ $TMPDIR/fp-latest.json
			if [[ $FP_VERSION =~ [0-9]+\.[0-9]+\.[0] ]]; then
				# version x.x.0 means the first release of the major version, so strip off the .0 and download version x.x
				LATEST_VERSION=${FP_VERSION%??}
			else
				# otherwise, scan the releases and get the most up to date minor version of the major release
				local VERSION_ESCAPED=`echo $FP_VERSION | sed 's/\./\\\\./g'`
				LATEST_VERSION=$(grep -o '"version":"'$VERSION_ESCAPED'[^"]*' $TMPDIR/fp-latest.json | sed 's/"version":"//' | head -1)
			fi
			if [[ -z "$LATEST_VERSION" ]]; then
				local ARCHIVE_NAME="finpress-$FP_VERSION"
			else
				local ARCHIVE_NAME="finpress-$LATEST_VERSION"
			fi
		else
			local ARCHIVE_NAME="finpress-$FP_VERSION"
		fi
		download https://finpress.org/${ARCHIVE_NAME}.tar.gz  $TMPDIR/finpress.tar.gz
		tar --strip-components=1 -zxmf $TMPDIR/finpress.tar.gz -C $FP_CORE_DIR
	fi

	download https://raw.githubusercontent.com/markoheijnen/fp-mysqli/master/db.php $FP_CORE_DIR/fp-content/db.php
}

install_test_suite() {
	# portable in-place argument for both GNU sed and Mac OSX sed
	if [[ $(uname -s) == 'Darwin' ]]; then
		local ioption='-i.bak'
	else
		local ioption='-i'
	fi

	# set up testing suite if it doesn't yet exist
	if [ ! -d $FP_TESTS_DIR ]; then
		# set up testing suite
		mkdir -p $FP_TESTS_DIR
		rm -rf $FP_TESTS_DIR/{includes,data}
        check_svn_installed
		svn export --quiet --ignore-externals https://develop.svn.finpress.org/${FP_TESTS_TAG}/tests/phpunit/includes/ $FP_TESTS_DIR/includes
		svn export --quiet --ignore-externals https://develop.svn.finpress.org/${FP_TESTS_TAG}/tests/phpunit/data/ $FP_TESTS_DIR/data
	fi

	if [ ! -f fp-tests-config.php ]; then
		download https://develop.svn.finpress.org/${FP_TESTS_TAG}/fp-tests-config-sample.php "$FP_TESTS_DIR"/fp-tests-config.php
		# remove all forward slashes in the end
		FP_CORE_DIR=$(echo $FP_CORE_DIR | sed "s:/\+$::")
		sed $ioption "s:dirname( __FILE__ ) . '/src/':'$FP_CORE_DIR/':" "$FP_TESTS_DIR"/fp-tests-config.php
		sed $ioption "s:__DIR__ . '/src/':'$FP_CORE_DIR/':" "$FP_TESTS_DIR"/fp-tests-config.php
		sed $ioption "s/youremptytestdbnamehere/$DB_NAME/" "$FP_TESTS_DIR"/fp-tests-config.php
		sed $ioption "s/yourusernamehere/$DB_USER/" "$FP_TESTS_DIR"/fp-tests-config.php
		sed $ioption "s/yourpasswordhere/$DB_PASS/" "$FP_TESTS_DIR"/fp-tests-config.php
		sed $ioption "s|localhost|${DB_HOST}|" "$FP_TESTS_DIR"/fp-tests-config.php
	fi

}

recreate_db() {
	shopt -s nocasematch
	if [[ $1 =~ ^(y|yes)$ ]]
	then
		mysqladmin drop $DB_NAME -f --user="$DB_USER" --password="$DB_PASS"$EXTRA
		create_db
		echo "Recreated the database ($DB_NAME)."
	else
		echo "Leaving the existing database ($DB_NAME) in place."
	fi
	shopt -u nocasematch
}

create_db() {
	mysqladmin create $DB_NAME --user="$DB_USER" --password="$DB_PASS"$EXTRA
}

install_db() {

	if [ ${SKIP_DB_CREATE} = "true" ]; then
		return 0
	fi

	# parse DB_HOST for port or socket references
	local PARTS=(${DB_HOST//\:/ })
	local DB_HOSTNAME=${PARTS[0]};
	local DB_SOCK_OR_PORT=${PARTS[1]};
	local EXTRA=""

	if ! [ -z $DB_HOSTNAME ] ; then
		if [ $(echo $DB_SOCK_OR_PORT | grep -e '^[0-9]\{1,\}$') ]; then
			EXTRA=" --host=$DB_HOSTNAME --port=$DB_SOCK_OR_PORT --protocol=tcp"
		elif ! [ -z $DB_SOCK_OR_PORT ] ; then
			EXTRA=" --socket=$DB_SOCK_OR_PORT"
		elif ! [ -z $DB_HOSTNAME ] ; then
			EXTRA=" --host=$DB_HOSTNAME --protocol=tcp"
		fi
	fi

	# create database
	if [ $(mysql --user="$DB_USER" --password="$DB_PASS"$EXTRA --execute='show databases;' | grep ^$DB_NAME$) ]
	then
		echo "Reinstalling will delete the existing test database ($DB_NAME)"
		read -p 'Are you sure you want to proceed? [y/N]: ' DELETE_EXISTING_DB
		recreate_db $DELETE_EXISTING_DB
	else
		create_db
	fi
}

install_fp
install_test_suite
install_db
