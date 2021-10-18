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

# placeholders in the template
ESCAPE_PREFIX=__
ESCAPE_SUFFIX=__

WEEKDAY_PLACEHOLDER=${ESCAPE_PREFIX}WEEKDAY${ESCAPE_SUFFIX}
DAY_PLACEHOLDER=${ESCAPE_PREFIX}DAY${ESCAPE_SUFFIX}
MONTH_PLACEHOLDER=${ESCAPE_PREFIX}MONTH${ESCAPE_SUFFIX}
YEAR_PLACEHOLDER=${ESCAPE_PREFIX}YEAR${ESCAPE_SUFFIX}
ROOM_PLACEHOLDER=${ESCAPE_PREFIX}ROOM${ESCAPE_SUFFIX}
LOCATION_PLACEHOLDER=${ESCAPE_PREFIX}LOCATION${ESCAPE_SUFFIX}
PARMA_PLACEHOLDER=${ESCAPE_PREFIX}PARMA${ESCAPE_SUFFIX}
DITAM_PLACEHOLDER=${ESCAPE_PREFIX}DITAM${ESCAPE_SUFFIX}
SUBMISSION_LINK_PLACEHOLDER=${ESCAPE_PREFIX}SUBMISSION_LINK${ESCAPE_SUFFIX}

THE_SUBMISSION_CALENDAR_PLACEHOLDER=${ESCAPE_PREFIX}THE_SUBMISSION_CALENDAR${ESCAPE_SUFFIX}
THE_REAL_CAMERA_DATE_PLACEHOLDER=${ESCAPE_PREFIX}THE_REAL_CAMERA_DATE${ESCAPE_SUFFIX}

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
  for d in $1; do
    if [[ ! ( -z "$cur" ) ]]; then
      printf '<li><strike>%s</strike></li>' "$cur"
      cur="$4""$d""$5"
    else
      cur="$2""$d""$3"
    fi
  done
  printf '<li>%s</li>' "$cur"
}

make_real_date()
{
  # $1: list of dates
  # $2: non-extended prefix
  # $3: non-extended suffix
  # $4: extended prefix
  # $5: extended suffix
  cur=
  for d in $1; do
    if [[ ! ( -z "$cur" ) ]]; then
      printf '<strike>%s</strike> ' "$cur"
      cur="$4""$d""$5"
    else
      cur="$2""$d""$3"
    fi
  done
  printf '%s' "$cur"
}

subm_date_html=$(make_items \
  "${SUBMISSION_DATES}" \
  '' ' - 11:59 PM (UTC): Paper Submission Deadline' \
  '<font color="#FF0000"><b>' '- 11:59 PM (UTC): NEW EXTENDED Paper Submission Deadline</b></font>')
accp_date_html=$(make_items \
  "${ACCEPTANCE_DATES}" \
  '' ': Acceptance Notification' \
  '' '<b>(EXTENDED deadline)</b> Acceptance Notification')
cdry_date_html=$(make_items \
  "${CAMERA_DATES}" \
  '' ': <a href= "./Submission_Guidelines.html">Camera ready</a> version of accepted papers for workshop proceedings' \
  '' ': <b>(EXTENDED deadline)</b> <a href= "./Submission_Guidelines.html">Camera ready</a> version of accepted papers for workshop proceedings')
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
	sed -i '' "s%${WEEKDAY_PLACEHOLDER}%${WEEKDAY_DATA}%g" ${WIP_FILE}
	sed -i '' "s%${DAY_PLACEHOLDER}%${DAY_DATA}%g" ${WIP_FILE}
	sed -i '' "s%${MONTH_PLACEHOLDER}%${MONTH_DATA}%g" ${WIP_FILE}
	sed -i '' "s%${YEAR_PLACEHOLDER}%${YEAR_DATA}%g" ${WIP_FILE}
	sed -i '' "s%${ROOM_PLACEHOLDER}%${ROOM_DATA}%g" ${WIP_FILE}
	sed -i '' "s%${LOCATION_PLACEHOLDER}%${LOCATION_DATA}%g" ${WIP_FILE}
	sed -i '' "s|${SUBMISSION_LINK_PLACEHOLDER}|${SUBMISSION_LINK_DATA}|" ${WIP_FILE}
	# edition numbers
	sed -i '' "s%${PARMA_PLACEHOLDER}%${PARMA_DATA}%g" ${WIP_FILE}
	sed -i '' "s%${DITAM_PLACEHOLDER}%${DITAM_DATA}%g" ${WIP_FILE}
  # submission calendar et al
	sed -i '' "s%${THE_SUBMISSION_CALENDAR_PLACEHOLDER}%${THE_SUBMISSION_CALENDAR}%g" ${WIP_FILE}
	sed -i '' "s%${THE_REAL_CAMERA_DATE_PLACEHOLDER}%${THE_REAL_CAMERA_DATE}%g" ${WIP_FILE}
done

mv ${TMP_FILE_INDEX} ${FINAL_FILE_INDEX}
mv ${TMP_FILE_PROGRAM} ${FINAL_FILE_PROGRAM}
mv ${TMP_FILE_GUIDELINES} ${FINAL_FILE_GUIDELINES}
