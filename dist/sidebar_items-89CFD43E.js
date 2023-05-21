sidebarNodes={"extras":[{"group":"","headers":[{"anchor":"modules","id":"Modules"}],"id":"api-reference","title":"API Reference"},{"group":"","headers":[{"anchor":"introduction","id":"Introduction"},{"anchor":"authentication","id":"Authentication"},{"anchor":"performing-authenticated-api-requests","id":"Performing authenticated API requests"},{"anchor":"sites","id":"Sites"},{"anchor":"participants","id":"Participants"},{"anchor":"study-structure","id":"Study Structure"},{"anchor":"collected-data","id":"Collected Data"},{"anchor":"study-data","id":"Study Data"},{"anchor":"wrapping-up","id":"Wrapping up"}],"id":"getting_started","title":"Using the Castor EDC API"}],"modules":[{"group":"","id":"CastorEDC","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"authenticate/1","id":"authenticate/1","title":"authenticate(client)"}]}],"sections":[],"title":"CastorEDC"},{"group":"","id":"CastorEDC.Client","nodeGroups":[{"key":"types","name":"Types","nodes":[{"anchor":"t:credentials/0","id":"credentials/0","title":"credentials()"},{"anchor":"t:t/0","id":"t/0","title":"t()"},{"anchor":"t:url/0","id":"url/0","title":"url()"},{"anchor":"t:uuid/0","id":"uuid/0","title":"uuid()"}]},{"key":"functions","name":"Functions","nodes":[{"anchor":"new/2","id":"new/2","title":"new(credentials, opts \\\\ [])"}]}],"sections":[],"title":"CastorEDC.Client"},{"group":"Common","id":"CastorEDC.Common.Countries","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/2","id":"find/2","title":"find(client, country_id)"},{"anchor":"list/1","id":"list/1","title":"list(client)"}]}],"sections":[],"title":"CastorEDC.Common.Countries"},{"group":"Common","id":"CastorEDC.Common.Sites","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"create/3","id":"create/3","title":"create(client, study_id, body)"},{"anchor":"find/4","id":"find/4","title":"find(client, study_id, site_id, params \\\\ [])"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.Common.Sites"},{"group":"Common","id":"CastorEDC.Common.Studies","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/2","id":"find/2","title":"find(client, study_id)"},{"anchor":"list/1","id":"list/1","title":"list(client)"}]}],"sections":[],"title":"CastorEDC.Common.Studies"},{"group":"Common","id":"CastorEDC.Common.Studies.Roles","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"create/3","id":"create/3","title":"create(client, study_id, body)"},{"anchor":"find/3","id":"find/3","title":"find(client, study_id, role_name)"},{"anchor":"list/2","id":"list/2","title":"list(client, study_id)"}]}],"sections":[],"title":"CastorEDC.Common.Studies.Roles"},{"group":"Common","id":"CastorEDC.Common.Studies.Users","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/3","id":"find/3","title":"find(client, study_id, user_id)"},{"anchor":"list/2","id":"list/2","title":"list(client, study_id)"}]}],"sections":[],"title":"CastorEDC.Common.Studies.Users"},{"group":"Common","id":"CastorEDC.Common.Users","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/2","id":"find/2","title":"find(client, user_id)"},{"anchor":"list/1","id":"list/1","title":"list(client)"}]}],"sections":[],"title":"CastorEDC.Common.Users"},{"group":"Data Collection","id":"CastorEDC.DataCollection.DataEntry.RepeatingDataDataPoint","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"create/6","id":"create/6","title":"create(client, study_id, participant_id, repeating_data_instance_id, field_id, body)"},{"anchor":"find/6","id":"find/6","title":"find(client, study_id, participant_id, repeating_data_instance_id, field_id, params \\\\ [])"},{"anchor":"list/5","id":"list/5","title":"list(client, study_id, participant_id, repeating_data_instance_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.DataCollection.DataEntry.RepeatingDataDataPoint"},{"group":"Data Collection","id":"CastorEDC.DataCollection.DataEntry.StudyDataPoint","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"create/5","id":"create/5","title":"create(client, study_id, participant_id, field_id, body)"},{"anchor":"find/5","id":"find/5","title":"find(client, study_id, participant_id, field_id, params \\\\ [])"},{"anchor":"list/4","id":"list/4","title":"list(client, study_id, participant_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.DataCollection.DataEntry.StudyDataPoint"},{"group":"Data Collection","id":"CastorEDC.DataCollection.DataEntry.SurveyDataPoint","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"create/6","id":"create/6","title":"create(client, study_id, participant_id, survey_instance_id, field_id, body)"},{"anchor":"find/6","id":"find/6","title":"find(client, study_id, participant_id, survey_instance_id, field_id, params \\\\ [])"},{"anchor":"list/5","id":"list/5","title":"list(client, study_id, participant_id, survey_instance_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.DataCollection.DataEntry.SurveyDataPoint"},{"group":"Data Collection","id":"CastorEDC.DataCollection.DataPoints.RepeatingDataInstanceDataPointCollection","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"create/5","id":"create/5","title":"create(client, study_id, participant_id, repeating_data_instance_id, body)"},{"anchor":"find/4","id":"find/4","title":"find(client, study_id, repeating_data_instance_id, params \\\\ [])"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.DataCollection.DataPoints.RepeatingDataInstanceDataPointCollection"},{"group":"Data Collection","id":"CastorEDC.DataCollection.DataPoints.StudyDataPointCollection","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"create/4","id":"create/4","title":"create(client, study_id, participant_id, body)"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.DataCollection.DataPoints.StudyDataPointCollection"},{"group":"Data Collection","id":"CastorEDC.DataCollection.DataPoints.SurveyInstanceDataPointCollection","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"create/5","id":"create/5","title":"create(client, study_id, participant_id, survey_instance_id, body)"},{"anchor":"find/4","id":"find/4","title":"find(client, study_id, survey_instance_id, params \\\\ [])"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.DataCollection.DataPoints.SurveyInstanceDataPointCollection"},{"group":"Data Collection","id":"CastorEDC.DataCollection.DataPoints.SurveyPackageInstanceDataPointCollection","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"create/5","id":"create/5","title":"create(client, study_id, participant_id, survey_package_instance_id, body)"},{"anchor":"list/4","id":"list/4","title":"list(client, study_id, survey_package_instance_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.DataCollection.DataPoints.SurveyPackageInstanceDataPointCollection"},{"group":"Data Collection","id":"CastorEDC.DataCollection.Participants","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"create/3","id":"create/3","title":"create(client, study_id, body)"},{"anchor":"find/3","id":"find/3","title":"find(client, study_id, participant_id)"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.DataCollection.Participants"},{"group":"Data Collection","id":"CastorEDC.DataCollection.Participants.Progress","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.DataCollection.Participants.Progress"},{"group":"Data Collection","id":"CastorEDC.DataCollection.Participants.RepeatingDataInstances","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"create/4","id":"create/4","title":"create(client, study_id, participant_id, body)"},{"anchor":"find/4","id":"find/4","title":"find(client, study_id, participant_id, repeating_data_instance_id)"},{"anchor":"list/4","id":"list/4","title":"list(client, study_id, participant_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.DataCollection.Participants.RepeatingDataInstances"},{"group":"Data Collection","id":"CastorEDC.DataCollection.Participants.SurveyPackageInstances","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"patch/5","id":"patch/5","title":"patch(client, study_id, participant_id, survey_package_instance_id, body)"}]}],"sections":[],"title":"CastorEDC.DataCollection.Participants.SurveyPackageInstances"},{"group":"Data Collection","id":"CastorEDC.DataCollection.Queries","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/4","id":"find/4","title":"find(client, study_id, query_id, params \\\\ [])"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.DataCollection.Queries"},{"group":"Data Collection","id":"CastorEDC.DataCollection.Randomization","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"create/3","id":"create/3","title":"create(client, study_id, participant_id)"},{"anchor":"find/3","id":"find/3","title":"find(client, study_id, participant_id)"}]}],"sections":[],"title":"CastorEDC.DataCollection.Randomization"},{"group":"Data Collection","id":"CastorEDC.DataCollection.RepeatingDataInstances","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/3","id":"find/3","title":"find(client, study_id, repeating_data_instance_id)"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.DataCollection.RepeatingDataInstances"},{"group":"Data Collection","id":"CastorEDC.DataCollection.Statistics","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/2","id":"find/2","title":"find(client, study_id)"}]}],"sections":[],"title":"CastorEDC.DataCollection.Statistics"},{"group":"Data Collection","id":"CastorEDC.DataCollection.SurveyPackageInstances","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"create/3","id":"create/3","title":"create(client, study_id, body)"},{"anchor":"find/3","id":"find/3","title":"find(client, study_id, survey_package_instance_id)"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"},{"anchor":"patch/4","id":"patch/4","title":"patch(client, study_id, survey_package_instance_id, body)"}]}],"sections":[],"title":"CastorEDC.DataCollection.SurveyPackageInstances"},{"group":"Data Collection","id":"CastorEDC.DataCollection.Verifications","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.DataCollection.Verifications"},{"group":"Study Protocol","id":"CastorEDC.StudyProtocol.FieldDependencies","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/4","id":"find/4","title":"find(client, study_id, field_dependency_id, params \\\\ [])"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.StudyProtocol.FieldDependencies"},{"group":"Study Protocol","id":"CastorEDC.StudyProtocol.FieldValidations","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/4","id":"find/4","title":"find(client, study_id, field_validation_id, params \\\\ [])"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.StudyProtocol.FieldValidations"},{"group":"Study Protocol","id":"CastorEDC.StudyProtocol.Fields","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/4","id":"find/4","title":"find(client, study_id, field_id, params \\\\ [])"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.StudyProtocol.Fields"},{"group":"Study Protocol","id":"CastorEDC.StudyProtocol.Forms","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/4","id":"find/4","title":"find(client, study_id, form_id, params \\\\ [])"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.StudyProtocol.Forms"},{"group":"Study Protocol","id":"CastorEDC.StudyProtocol.Metadata","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/4","id":"find/4","title":"find(client, study_id, metadata_id, params \\\\ [])"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.StudyProtocol.Metadata"},{"group":"Study Protocol","id":"CastorEDC.StudyProtocol.MetadataTypes","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/4","id":"find/4","title":"find(client, study_id, metadata_type_id, params \\\\ [])"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.StudyProtocol.MetadataTypes"},{"group":"Study Protocol","id":"CastorEDC.StudyProtocol.OptionGroups","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/4","id":"find/4","title":"find(client, study_id, option_group_id, params \\\\ [])"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.StudyProtocol.OptionGroups"},{"group":"Study Protocol","id":"CastorEDC.StudyProtocol.RepeatingData","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/3","id":"find/3","title":"find(client, study_id, repeating_data_id)"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.StudyProtocol.RepeatingData"},{"group":"Study Protocol","id":"CastorEDC.StudyProtocol.RepeatingDataForms","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/5","id":"find/5","title":"find(client, study_id, repeating_data_id, repeating_data_form_id, params \\\\ [])"},{"anchor":"list/4","id":"list/4","title":"list(client, study_id, repeating_data_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.StudyProtocol.RepeatingDataForms"},{"group":"Study Protocol","id":"CastorEDC.StudyProtocol.SurveyForms","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/5","id":"find/5","title":"find(client, study_id, survey_id, survey_form_id, params \\\\ [])"},{"anchor":"list/4","id":"list/4","title":"list(client, study_id, survey_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.StudyProtocol.SurveyForms"},{"group":"Study Protocol","id":"CastorEDC.StudyProtocol.SurveyPackages","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/3","id":"find/3","title":"find(client, study_id, survey_package_id)"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.StudyProtocol.SurveyPackages"},{"group":"Study Protocol","id":"CastorEDC.StudyProtocol.Surveys","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/3","id":"find/3","title":"find(client, study_id, survey_id)"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.StudyProtocol.Surveys"},{"group":"Study Protocol","id":"CastorEDC.StudyProtocol.Visits","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"anchor":"find/4","id":"find/4","title":"find(client, study_id, visit_id, params \\\\ [])"},{"anchor":"list/3","id":"list/3","title":"list(client, study_id, params \\\\ [])"}]}],"sections":[],"title":"CastorEDC.StudyProtocol.Visits"}],"tasks":[]}