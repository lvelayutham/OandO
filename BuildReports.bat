@echo off
set _exitStatus=0
set _argcActual=0
set _argcExpected=3

echo.

for %%i in (%*) do set /A _argcActual+=1

if %_argcActual% NEQ %_argcExpected% (

  call :_ShowUsage %0%, "Incorrect Usage."

  set _exitStatus=1

  goto:_EOF
)

call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat"

IF EXIST C:\reportsdevelopment\Buildlog.txt DEL C:\reportsdevelopment\Buildlog.txt

"C:\Program Files (x86)\SourceGear\Vault Client\vault.exe" Get "$/Dovetail Reporting DB/" -host acmcorprod:90 -user sraghunath -password Dovetailvault -repository "DovetailOutcomesAndOperationsReports" >> C:\reportsdevelopment\Buildlog.txt
"C:\Program Files (x86)\SourceGear\Vault Client\vault.exe" Get "$/Dovetail ETL/" -host acmcorprod:90 -user sraghunath -password Dovetailvault -repository "DovetailOutcomesAndOperationsReports" >> C:\reportsdevelopment\Buildlog.txt
"C:\Program Files (x86)\SourceGear\Vault Client\vault.exe" Get "$/DovetailReportsDevelopment/" -host acmcorprod:90 -user sraghunath -password Dovetailvault -repository "DovetailOutcomesAndOperationsReports" >> C:\reportsdevelopment\Buildlog.txt
"C:\Program Files (x86)\SourceGear\Vault Client\vault.exe" Get "$/" -host acmcorprod:90 -user sraghunath -password Dovetailvault -repository "DovetailOutcomesAndOperationsReports" >> C:\reportsdevelopment\Buildlog.txt

ECHO Copying Create SQL scripts
xcopy "C:\ReportsDevelopment\Dovetail Reporting DB\CreateScripts" "S:\DHMSReportingReleases\%1\%1.%2.%3\SQL\CreateScripts"  /i /s /y /q >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\Dovetail Reporting DB\CreateDovetail_ReportingDB.sql" "S:\DHMSReportingReleases\%1\%1.%2.%3\SQL\CreateDovetail_ReportingDB.sql"  /y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\Dovetail Reporting DB\UpgradeDovetail_ReportingDB.sql" "S:\DHMSReportingReleases\%1\%1.%2.%3\SQL\UpgradeDovetail_ReportingDB.sql"  /y >> C:\reportsdevelopment\Buildlog.txt

ECHO Copying Update SQL scripts
xcopy "C:\ReportsDevelopment\Dovetail Reporting DB\UpgradeScripts\%1.%2" "S:\DHMSReportingReleases\%1\%1.%2.%3\SQL\UpgradeScripts"  /i /s /y /q >> C:\reportsdevelopment\Buildlog.txt

ECHO Copying Test Data
xcopy "C:\ReportsDevelopment\Dovetail Reporting DB\TestData" "S:\DHMSReportingReleases\%1\%1.%2.%3\SQL\TestData"  /i /s /y /q >> C:\reportsdevelopment\Buildlog.txt

ECHO Copying ETL Packages
xcopy "C:\ReportsDevelopment\Dovetail ETL\*.dtsx" "S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Test"  /i /s /y /q >> C:\reportsdevelopment\Buildlog.txt
xcopy "C:\ReportsDevelopment\Dovetail ETL\*.dtsx" "S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Stage"  /i /s /y /q >> C:\reportsdevelopment\Buildlog.txt
xcopy "C:\ReportsDevelopment\Dovetail ETL\*.dtsx" "S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Production"  /i /s /y /q >> C:\reportsdevelopment\Buildlog.txt

ECHO configure ETL Test Packages using FART
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Test\*.dtsx @REPSVRNAME@ REPORTING-TEST >> C:\reportsdevelopment\Buildlog.txt
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Test\*.dtsx @DTDBSVRNAME@ DHMS-DB-2k8 >> C:\reportsdevelopment\Buildlog.txt
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Test\*.dtsx @STDBSVRNAME@ DHMS-AP-TSTSTWD >> C:\reportsdevelopment\Buildlog.txt
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Test\*.dtsx @DTDHMSURL@ http://dhms-hhc-2k8 >> C:\reportsdevelopment\Buildlog.txt
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Test\*.dtsx @STDHMSURL@ http://dhms-ap-tststwd >> C:\reportsdevelopment\Buildlog.txt

ECHO configure ETL Stage Packages using FART
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Stage\*.dtsx @REPSVRNAME@ ACMREPSTAGE >> C:\reportsdevelopment\Buildlog.txt
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Stage\*.dtsx @DTDBSVRNAME@ DTDBSTAGING >> C:\reportsdevelopment\Buildlog.txt
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Stage\*.dtsx @STDBSVRNAME@ STWDDBSTAGING.STWD.LOCAL >> C:\reportsdevelopment\Buildlog.txt
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Stage\*.dtsx @DTDHMSURL@ https://staging-dhms-dovetail.dovetailhealth.com >> C:\reportsdevelopment\Buildlog.txt
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Stage\*.dtsx @STDHMSURL@ https://staging-dhms-steward.dovetailhealth.com >> C:\reportsdevelopment\Buildlog.txt

ECHO configure ETL Production Packages using FART
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Production\*.dtsx @REPSVRNAME@ REPORTING >> C:\reportsdevelopment\Buildlog.txt
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Production\*.dtsx @DTDBSVRNAME@ DTDBPRODUCTION >> C:\reportsdevelopment\Buildlog.txt
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Production\*.dtsx @STDBSVRNAME@ STWDDBPRODUCTION.STWD.LOCAL >> C:\reportsdevelopment\Buildlog.txt
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Production\*.dtsx @DTDHMSURL@ https://dhms-dovetail.dovetailhealth.com >> C:\reportsdevelopment\Buildlog.txt
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Packages\Production\*.dtsx @STDHMSURL@ https://dhms-steward.dovetailhealth.com >> C:\reportsdevelopment\Buildlog.txt




ECHO Copying ETL configurations
xcopy "C:\ReportsDevelopment\Dovetail ETL\ETL_Configurations" "S:\DHMSReportingReleases\%1\%1.%2.%3\ETL_Configurations"  /i /s /y /q >> C:\reportsdevelopment\Buildlog.txt

ECHO Building Reports
REM devenv /Rebuild /project C:\ReportsDevelopment\DovetailReportsDevelopment\DovetailReportsDevelopment.rptproj >> C:\reportsdevelopment\Buildlog.txt
REM devenv /Rebuild /project "C:\ReportsDevelopment\DovetailReportsDevelopment\Enrollment reports\Enrollment reports.rptproj" >> C:\reportsdevelopment\Buildlog.txt
REM devenv /Rebuild /project C:\ReportsDevelopment\DovetailReportsDevelopment\ProductionOperationReports\ProductionOperationReports.rptproj >> C:\reportsdevelopment\Buildlog.txt

ECHO Copying Admin Reports
IF NOT EXIST S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Admin mkdir S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Admin
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\ProductionOperationReports\Monitor DHMS Gateway.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Admin\Monitor DHMS Gateway.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\SF12 report.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Admin\SF12 Report.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy C:\ReportsDevelopment\DovetailReportsDevelopment\ProductionOperationReports\SSIS_Error_Log_Report.rdl "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Admin\SSIS Error Log Report.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy C:\ReportsDevelopment\DovetailReportsDevelopment\ProductionOperationReports\SSIS_Process_Log.rdl "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Admin\SSIS Process Log.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy C:\ReportsDevelopment\DovetailReportsDevelopment\ProductionOperationReports\Steward_TMOT_Sync_Log.rdl "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Admin\Steward TMOT Sync Log.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy C:\ReportsDevelopment\DovetailReportsDevelopment\ProductionOperationReports\TMOT_Sync_Log.rdl "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Admin\TMOT Sync Log.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt

ECHO Copying Data Quality Reports
IF NOT EXIST "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Data Quality" mkdir "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Data Quality"
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\CrossCheck InsuranceId.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Data Quality\CrossCheck InsuranceId.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Duplicated insurance IDs.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Data Quality\Duplicated Insurance IDs.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Duplicated visit RN-RX.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Data Quality\Duplicated Visit RN-RX.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Encounters Frequency Report.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Data Quality\Encounters Frequency Report.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Member data quality check.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Data Quality\Member Data Quality Check.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Notes outside program dates.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Data Quality\Notes Outside Program Dates.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Program data quality check.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Data Quality\Program Data Quality Check.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Unassociated Medication Issues.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Data Quality\Unassociated Medication Issues.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt


ECHO Copying Management Reports
IF NOT EXIST S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Management mkdir S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Management
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\6 month Enrollment Report.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Management\6 Month Enrollment Report.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Clinician Panel Size.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Management\Clinician Panel Size.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Complex Care Nurses Clinician Dashboard.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Management\Complex Care Nurses Clinician Dashboard.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Enrollment Coordinator Conversion Rate.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Management\Enrollment Coordinator Conversion Rate.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Patient Home Visit Summary Report.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Management\Patient Home Visit Summary Report.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Transition Pharmacist Clinician Dashboard.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Management\Transition Pharmacist Clinician Dashboard.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\ECCR_ProgramType Programs.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Management\ECCR_ProgramType Programs.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\ECCR_All Programs.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Management\ECCR_All Programs.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt




ECHO Copying Operational Reports
xcopy "C:\ReportsDevelopment\DovetailReportsDevelopment\Enrollment reports\*.rdl" S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Operational /i /s /y /q >> C:\reportsdevelopment\Buildlog.txt
xcopy "C:\ReportsDevelopment\DovetailReportsDevelopment\Enrollment reports\*.jpg" S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Operational /i /s /y /q >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Call Enrollment Report.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Operational\Call Enrollment Report.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Appointment Cadence Report.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Operational\Appointment Cadence Report.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\NCQA QI7 Audit.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Operational\NCQA QI7 Audit.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Patient Census MultiTab.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Operational\Patient Census MultiTab.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Patient Census SingleTab.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Operational\Patient Census SingleTab.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Patient Tracker Report.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Operational\Patient Tracker Report.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\pharmacistPanel.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Operational\Pharmacist Panel.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Tufts Member Level Variables.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Operational\Tufts Member Level Variables.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Tufts Process Metrics Report.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Operational\Tufts Process Metrics Report.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Tufts Medicare Preferred - Caregiver Strain Survey.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Operational\Tufts Medicare Preferred - Caregiver Strain Survey.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Tufts Medicare Preferred - Quality of Life.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Operational\Tufts Medicare Preferred - Quality of Life.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\UR Meeting Prep.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Operational\UR Meeting Prep.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt

ECHO Copying Outcomes Reports
IF NOT EXIST S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes mkdir S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\check ACG counts.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\check ACG counts.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Compare Readmission Rates.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\Compare Readmission Rates.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Compare Readmission Rate - drilldown.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\Compare Readmission Rate - drilldown.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Cost and utilization report.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\Cost and Utilization Report.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Cost and utilization Control Population.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\Cost and utilization Control Population.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Cost and utilization Control Population Body.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\Cost and utilization Control Population Body.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Cost and utilization Control Population Stats.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\Cost and utilization Control Population Stats.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Cost and utilization Control Population Enroll.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\Cost and utilization Control Population Enroll.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Cost and utilization Control Population Visualize.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\Cost and utilization Control Population Visualize.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Cost and utilization random Control Population.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\Cost and utilization random Control Population.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\CostUtilizationDrillDown.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\CostUtilizationDrillDown.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\MedicationIssuesByMember.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\MedicationIssuesByMember.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Medication Issue Report - Diff ratio.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\Medication Issue Report - Diff ratio.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Medication Issue Report.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\Medication Issue Report.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Population Acuity Report.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\Population Acuity Report.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Transition Program Dashboard.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\Transition Program Dashboard.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\STARS CMS Weekly Report.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\STARS CMS Weekly Report.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\STARS_CMS_Gaps_Subrpt.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\STARS_CMS_Gaps_Subrpt.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\STARS_CMS_Summary_Subrpt.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\STARS_CMS_Summary_Subrpt.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt
copy "C:\ReportsDevelopment\DovetailReportsDevelopment\Stars_Patient_Tracker_Report.rdl" "S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\Outcomes\Stars_Patient_Tracker_Report.rdl" /Y >> C:\reportsdevelopment\Buildlog.txt

ECHO Copying RSBuild
xcopy C:\ReportsDevelopment\DovetailReportsDevelopment\RSBuild S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\RSBuild /i /s /y /q >> C:\reportsdevelopment\Buildlog.txt

ECHO Calling FART to configure report version
C:\Tools\fart.exe -r S:\DHMSReportingReleases\%1\%1.%2.%3\Reports\*.rdl @Version@ %1.%2.%3 >> C:\reportsdevelopment\Buildlog.txt

goto:_EOF


:_ShowUsage

  echo [USAGE]: %~1 ReleaseVersion BuildVersion VaultRevisionNo
  echo [Example1]: %~1 3.3 0 1234
  echo [Example2]: %~1 3.3 3 1234
  echo.

  if NOT "%~2" == "" (

    echo %~2

    echo.
  )

  goto:eof

:_EOF

echo The exit status is %_exitStatus%.

echo.

cmd /c exit %_exitStatus%



