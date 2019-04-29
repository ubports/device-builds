#!/bin/bash

# Copyright (C) 2019  Dalton Durst
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Usage: 'check-gpg.sh [system-image server]'

# Checks the specified system-image server's GPG keys for expiry within 60 days. Exits
# with status 1 if any keys are expiring. Exits with status 2 if another error occurs.

fail() {
    echo "CHECK: $1"
    exit 2
}

SYSTEM_IMAGE_SERVER="$1"
IN_60_DAYS=$(expr $(date -u '+%s') + 5184000)
echo "CHECK: Checking server ${SYSTEM_IMAGE_SERVER}"

echo 'CHECK: Getting keys'
KEYS="archive-master image-master image-signing"
EXPIRED=''
for FILE in ${KEYS}; do
    FILENAME="${FILE}.tar.xz"
    GPGFILE="${FILE}.gpg"
    curl "${SYSTEM_IMAGE_SERVER}/gpg/${FILENAME}" -o "${FILENAME}" || fail "Couldn't get ${FILE}"
    tar -xf "${FILENAME}" 'keyring.gpg' || fail "Couldn't extract keyring from ${FILE}"
    mv 'keyring.gpg' "${GPGFILE}"
    EXPIRY=$(gpg --fixed-list-mode --with-colons "${GPGFILE}" | cut -d: -f7)
    if [ -z "${EXPIRY}" ]; then
        echo "CHECK: ${FILE} Does not expire."
        continue
    fi
    echo "CHECK: ${FILE} Expires on $(date -u --date="@${EXPIRY}")"
    if [ "${EXPIRY}" -lt "$IN_60_DAYS" ]; then
        EXPIRED="${EXPIRED} ${FILE}"
    fi

done

if [ -n "${EXPIRED}" ]; then
    echo 'CHECK: One or more keys are expiring in 60 days or less. Renew or replace these keys now:'
    echo "${EXPIRED}"
    exit 1
fi
exit 0
