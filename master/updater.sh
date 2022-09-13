#!/bin/bash -x

# files to operate on
TEMPLATE_FILE_GLOB_HEAD=`pwd`/__global_head.html
TEMPLATE_FILE_GLOB_FOOT=`pwd`/__global_foot.html

TEMPLATE_FILE_INDEX=`pwd`/_index.html
TMP_FILE_INDEX=`pwd`/index_tmp.html
FINAL_FILE_INDEX=`pwd`/../index.html

TEMPLATE_FILE_PROGRAM=`pwd`/_program.html
TMP_FILE_PROGRAM=`pwd`/program_tmp.html
FINAL_FILE_PROGRAM=`pwd`/../program.html

TEMPLATE_FILE_GUIDELINES=`pwd`/_submission.html
TMP_FILE_GUIDELINES=`pwd`/submission_tmp.html
FINAL_FILE_GUIDELINES=`pwd`/../Submission_Guidelines.html

# read config
source ../.data/config.sh

# construct submission calendar
make_items()
{
  # $1: list of dates
  # $2: non-extended prefix
  # $3: non-extended suffix
  # $4: extended prefix
  # $5: extended suffix
  cur=
  lastd=
  for d in $1; do
    if [[ ! ( -z "$cur" ) ]]; then
      printf '<li><strike>%s</strike></li>' "$cur"
      cur="$2""$d""$3"
      lastd="$4""$d""$5"
    else
      cur="$2""$d""$3"
      lastd="$cur"
    fi
  done
  printf '<li>%s</li>' "$lastd"
}

make_real_date()
{
  # $1: list of dates
  # $2: non-extended prefix
  # $3: non-extended suffix
  # $4: extended prefix
  # $5: extended suffix
  cur=
  lastd=
  for d in $1; do
    if [[ ! ( -z "$cur" ) ]]; then
      printf '<strike>%s</strike> ' "$cur"
      cur="$2""$d""$3"
      lastd="$4""$d""$5"
    else
      cur="$2""$d""$3"
      lastd="$cur"
    fi
  done
  printf '%s' "$lastd"
}

subm_date_html=$(make_items \
  "${SUBMISSION_DATES}" \
  '' ' - 11:59 PM (UTC): Paper Submission Deadline' \
  '<font color="#FF0000"><b>' ' - 11:59 PM (UTC): NEW EXTENDED Paper Submission Deadline</b></font>')
accp_date_html=$(make_items \
  "${ACCEPTANCE_DATES}" \
  '' ': Acceptance Notification' \
  '<b>' ': (EXTENDED deadline)</b> Acceptance Notification')
cdry_date_html=$(make_items \
  "${CAMERA_DATES}" \
  '' ': Camera ready version of accepted papers for workshop proceedings' \
  '<b>' ': (EXTENDED deadline)</b> Camera ready version of accepted papers for workshop proceedings')
THE_SUBMISSION_CALENDAR="$subm_date_html$accp_date_html$cdry_date_html"

THE_REAL_CAMERA_DATE=$(make_real_date \
  "${CAMERA_DATES}" \
  '<b>' '</b>' \
  '<b>' '</b>')

# start processing
cat "$TEMPLATE_FILE_GLOB_HEAD" "$TEMPLATE_FILE_INDEX" "$TEMPLATE_FILE_GLOB_FOOT" > "$TMP_FILE_INDEX"
cat "$TEMPLATE_FILE_GLOB_HEAD" "${TEMPLATE_FILE_PROGRAM}" "$TEMPLATE_FILE_GLOB_FOOT" > "${TMP_FILE_PROGRAM}"
cat "$TEMPLATE_FILE_GLOB_HEAD" "${TEMPLATE_FILE_GUIDELINES}" "$TEMPLATE_FILE_GLOB_FOOT" > "${TMP_FILE_GUIDELINES}"

for WIP_FILE in "${TMP_FILE_PROGRAM}" "${TMP_FILE_INDEX}" "${TMP_FILE_GUIDELINES}"
do
	# workshop data
	sed -i '' "s%__WEEKDAY__%${WEEKDAY}%g" ${WIP_FILE}
	sed -i '' "s%__DAY__%${DAY}%g" ${WIP_FILE}
	sed -i '' "s%__MONTH__%${MONTH}%g" ${WIP_FILE}
	sed -i '' "s%__YEAR__%${YEAR}%g" ${WIP_FILE}
	sed -i '' "s%__ROOM__%${ROOM}%g" ${WIP_FILE}
	sed -i '' "s%__LOCATION__%${LOCATION}%g" ${WIP_FILE}
	sed -i '' "s%__HIPEAC_LINK__%${HIPEAC_LINK}%g" ${WIP_FILE}
	sed -i '' "s|__SUBMISSION_LINK__|${SUBMISSION_LINK}|" ${WIP_FILE}
	# index
	sed -i '' "s%__INDEX_ITEM_CFP__%${INDEX_ITEM_CFP}%g" ${WIP_FILE}
	sed -i '' "s%__INDEX_ITEM_SUBMISSION__%${INDEX_ITEM_SUBMISSION}%g" ${WIP_FILE}
	sed -i '' "s%__INDEX_ITEM_PROGRAM__%${INDEX_ITEM_PROGRAM}%g" ${WIP_FILE}
	sed -i '' "s%__INDEX_ITEM_PROGRAM_PDF__%${INDEX_ITEM_PROGRAM_PDF}%g" ${WIP_FILE}
	# edition numbers
	sed -i '' "s%__PARMA__%${PARMA}%g" ${WIP_FILE}
	sed -i '' "s%__DITAM__%${DITAM}%g" ${WIP_FILE}
  # submission calendar et al
	sed -i '' "s%__THE_SUBMISSION_CALENDAR__%${THE_SUBMISSION_CALENDAR}%g" ${WIP_FILE}
	sed -i '' "s%__THE_REAL_CAMERA_DATE__%${THE_REAL_CAMERA_DATE}%g" ${WIP_FILE}
done

mv ${TMP_FILE_INDEX} ${FINAL_FILE_INDEX}
mv ${TMP_FILE_PROGRAM} ${FINAL_FILE_PROGRAM}
mv ${TMP_FILE_GUIDELINES} ${FINAL_FILE_GUIDELINES}
