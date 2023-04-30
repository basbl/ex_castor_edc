searchNodes=[{"doc":"Facilitates authentication against the Castor EDC API alias CastorEDC.Client client = Client . new ( %{ client_id : &quot;&lt;client id&gt;&quot; , client_secret : &quot;&lt;client secret&gt;&quot; } ) { :ok , client } = CastorEDC . authenticate ( client ) See CastorEDC.Client.new/2 for all the options. After authenticating against the API you can then use the other modules to perform API requests, e.g: { 200 , list_of_studies , _ } = CastorEDC.Common.Studies . list ( client ) list_of_studies","ref":"CastorEDC.html","title":"CastorEDC","type":"module"},{"doc":"Exchanges a valid client id &amp; secret combination for an access token that can be used to make further API calls.","ref":"CastorEDC.html#authenticate/1","title":"CastorEDC.authenticate/1","type":"function"},{"doc":"Container for API client configuration values.","ref":"CastorEDC.Client.html","title":"CastorEDC.Client","type":"module"},{"doc":"By default the client will use https://data.castoredc.com/ as the endpoint client = Client . new ( %{ client_id : &quot;&lt;client id&gt;&quot; , client_secret : &quot;&lt;client secret&gt;&quot; } ) You can pass a different endpoint as an option when your studies are located elsewhere e.g. client = Client . new ( %{ client_id : &quot;&lt;client id&gt;&quot; , client_secret : &quot;&lt;client secret&gt;&quot; } , endpoint : &quot;https://us.castoredc.com/&quot; ) Alternatively, when you have a long-lived access token you can pass it in directly client = Client . new ( %{ access_token : &quot;&lt;access token&gt;&quot; } ) Additionally it's possible to pass options e.g increasing the global_timeout. client = Client . new ( %{ client_id : &quot;&lt;client id&gt;&quot; , client_secret : &quot;&lt;client secret&gt;&quot; } , global_timeout : 30_000 ) Options :endpoint - An alternative endpoint e.g. https://us.castoredc.com/ :global_timeout - The global_timeout in milliseconds, by default it is 5000 :adapter - Any module that implements the Tesla.Adapter behavior :adapter_options - The supported options for the given adapter","ref":"CastorEDC.Client.html#new/2","title":"CastorEDC.Client.new/2","type":"function"},{"doc":"","ref":"CastorEDC.Client.html#t:credentials/0","title":"CastorEDC.Client.credentials/0","type":"type"},{"doc":"","ref":"CastorEDC.Client.html#t:t/0","title":"CastorEDC.Client.t/0","type":"type"},{"doc":"","ref":"CastorEDC.Client.html#t:url/0","title":"CastorEDC.Client.url/0","type":"type"},{"doc":"","ref":"CastorEDC.Client.html#t:uuid/0","title":"CastorEDC.Client.uuid/0","type":"type"},{"doc":"Provides access to country related endpoints","ref":"CastorEDC.Common.Countries.html","title":"CastorEDC.Common.Countries","type":"module"},{"doc":"Find a specific country More info","ref":"CastorEDC.Common.Countries.html#find/2","title":"CastorEDC.Common.Countries.find/2","type":"function"},{"doc":"List all available countries More info","ref":"CastorEDC.Common.Countries.html#list/1","title":"CastorEDC.Common.Countries.list/1","type":"function"},{"doc":"Provides access to site related endpoints","ref":"CastorEDC.Common.Sites.html","title":"CastorEDC.Common.Sites","type":"module"},{"doc":"Create a single or multiple new site(s) More info","ref":"CastorEDC.Common.Sites.html#create/3","title":"CastorEDC.Common.Sites.create/3","type":"function"},{"doc":"Find a specific site More info","ref":"CastorEDC.Common.Sites.html#find/4","title":"CastorEDC.Common.Sites.find/4","type":"function"},{"doc":"List all sites More info","ref":"CastorEDC.Common.Sites.html#list/3","title":"CastorEDC.Common.Sites.list/3","type":"function"},{"doc":"Provides access to study related endpoints","ref":"CastorEDC.Common.Studies.html","title":"CastorEDC.Common.Studies","type":"module"},{"doc":"Find a specific study More info","ref":"CastorEDC.Common.Studies.html#find/2","title":"CastorEDC.Common.Studies.find/2","type":"function"},{"doc":"List all studies that the authenticated user is authorized to see More info","ref":"CastorEDC.Common.Studies.html#list/1","title":"CastorEDC.Common.Studies.list/1","type":"function"},{"doc":"Provides access to role related endpoints within the study context","ref":"CastorEDC.Common.Studies.Roles.html","title":"CastorEDC.Common.Studies.Roles","type":"module"},{"doc":"Create a new role More info","ref":"CastorEDC.Common.Studies.Roles.html#create/3","title":"CastorEDC.Common.Studies.Roles.create/3","type":"function"},{"doc":"Find a specific role within the study More info","ref":"CastorEDC.Common.Studies.Roles.html#find/3","title":"CastorEDC.Common.Studies.Roles.find/3","type":"function"},{"doc":"List all roles available within the study More info","ref":"CastorEDC.Common.Studies.Roles.html#list/2","title":"CastorEDC.Common.Studies.Roles.list/2","type":"function"},{"doc":"Provides access to user related endpoints within the study context","ref":"CastorEDC.Common.Studies.Users.html","title":"CastorEDC.Common.Studies.Users","type":"module"},{"doc":"Find a specific user that has access to the study More info","ref":"CastorEDC.Common.Studies.Users.html#find/3","title":"CastorEDC.Common.Studies.Users.find/3","type":"function"},{"doc":"List all users that have access to the given study More info","ref":"CastorEDC.Common.Studies.Users.html#list/2","title":"CastorEDC.Common.Studies.Users.list/2","type":"function"},{"doc":"Provides access to user related endpoints","ref":"CastorEDC.Common.Users.html","title":"CastorEDC.Common.Users","type":"module"},{"doc":"Find a specific user More info","ref":"CastorEDC.Common.Users.html#find/2","title":"CastorEDC.Common.Users.find/2","type":"function"},{"doc":"List all users that the authenticated user is authorized to see More info","ref":"CastorEDC.Common.Users.html#list/1","title":"CastorEDC.Common.Users.list/1","type":"function"},{"doc":"Provides access to repeating data data point related endpoints","ref":"CastorEDC.DataCollection.DataEntry.RepeatingDataDataPoint.html","title":"CastorEDC.DataCollection.DataEntry.RepeatingDataDataPoint","type":"module"},{"doc":"Create a new data point in a specific repeating data instance for a participant More info","ref":"CastorEDC.DataCollection.DataEntry.RepeatingDataDataPoint.html#create/6","title":"CastorEDC.DataCollection.DataEntry.RepeatingDataDataPoint.create/6","type":"function"},{"doc":"Find a data point for a participant in a specific repeating data instance More info","ref":"CastorEDC.DataCollection.DataEntry.RepeatingDataDataPoint.html#find/6","title":"CastorEDC.DataCollection.DataEntry.RepeatingDataDataPoint.find/6","type":"function"},{"doc":"List all collected repeating data instance data points for a participant More info","ref":"CastorEDC.DataCollection.DataEntry.RepeatingDataDataPoint.html#list/5","title":"CastorEDC.DataCollection.DataEntry.RepeatingDataDataPoint.list/5","type":"function"},{"doc":"Provides access to study data point related endpoints","ref":"CastorEDC.DataCollection.DataEntry.StudyDataPoint.html","title":"CastorEDC.DataCollection.DataEntry.StudyDataPoint","type":"module"},{"doc":"Create a new data point for a participant More info","ref":"CastorEDC.DataCollection.DataEntry.StudyDataPoint.html#create/5","title":"CastorEDC.DataCollection.DataEntry.StudyDataPoint.create/5","type":"function"},{"doc":"Find collected study data point for a participant in a field More info","ref":"CastorEDC.DataCollection.DataEntry.StudyDataPoint.html#find/5","title":"CastorEDC.DataCollection.DataEntry.StudyDataPoint.find/5","type":"function"},{"doc":"List all collected study data points for a participant More info","ref":"CastorEDC.DataCollection.DataEntry.StudyDataPoint.html#list/4","title":"CastorEDC.DataCollection.DataEntry.StudyDataPoint.list/4","type":"function"},{"doc":"Provides access to survey data point related endpoints","ref":"CastorEDC.DataCollection.DataEntry.SurveyDataPoint.html","title":"CastorEDC.DataCollection.DataEntry.SurveyDataPoint","type":"module"},{"doc":"Create a new data point in a specific survey instance for a participant More info","ref":"CastorEDC.DataCollection.DataEntry.SurveyDataPoint.html#create/6","title":"CastorEDC.DataCollection.DataEntry.SurveyDataPoint.create/6","type":"function"},{"doc":"Find a data point for a participant in a specific survey instance More info","ref":"CastorEDC.DataCollection.DataEntry.SurveyDataPoint.html#find/6","title":"CastorEDC.DataCollection.DataEntry.SurveyDataPoint.find/6","type":"function"},{"doc":"List all collected survey data points for a participant More info","ref":"CastorEDC.DataCollection.DataEntry.SurveyDataPoint.html#list/5","title":"CastorEDC.DataCollection.DataEntry.SurveyDataPoint.list/5","type":"function"},{"doc":"Provides access to repeating data instance data point collection for all participants","ref":"CastorEDC.DataCollection.DataPoints.RepeatingDataInstanceDataPointCollection.html","title":"CastorEDC.DataCollection.DataPoints.RepeatingDataInstanceDataPointCollection","type":"module"},{"doc":"Create/update a collection of field values for a repeating data instance More info","ref":"CastorEDC.DataCollection.DataPoints.RepeatingDataInstanceDataPointCollection.html#create/5","title":"CastorEDC.DataCollection.DataPoints.RepeatingDataInstanceDataPointCollection.create/5","type":"function"},{"doc":"List all collected data points for a specific repeating data instance More info","ref":"CastorEDC.DataCollection.DataPoints.RepeatingDataInstanceDataPointCollection.html#find/4","title":"CastorEDC.DataCollection.DataPoints.RepeatingDataInstanceDataPointCollection.find/4","type":"function"},{"doc":"List all collected data points for repeating data instances More info","ref":"CastorEDC.DataCollection.DataPoints.RepeatingDataInstanceDataPointCollection.html#list/3","title":"CastorEDC.DataCollection.DataPoints.RepeatingDataInstanceDataPointCollection.list/3","type":"function"},{"doc":"Provides access to study instance data point collection for all participants","ref":"CastorEDC.DataCollection.DataPoints.StudyDataPointCollection.html","title":"CastorEDC.DataCollection.DataPoints.StudyDataPointCollection","type":"module"},{"doc":"Create/update a collection of field values for a study More info","ref":"CastorEDC.DataCollection.DataPoints.StudyDataPointCollection.html#create/4","title":"CastorEDC.DataCollection.DataPoints.StudyDataPointCollection.create/4","type":"function"},{"doc":"List all collected data points for the study More info","ref":"CastorEDC.DataCollection.DataPoints.StudyDataPointCollection.html#list/3","title":"CastorEDC.DataCollection.DataPoints.StudyDataPointCollection.list/3","type":"function"},{"doc":"Provides access to survey instance data point collection for all participants","ref":"CastorEDC.DataCollection.DataPoints.SurveyInstanceDataPointCollection.html","title":"CastorEDC.DataCollection.DataPoints.SurveyInstanceDataPointCollection","type":"module"},{"doc":"Create/update a collection of field values for a survey instance More info","ref":"CastorEDC.DataCollection.DataPoints.SurveyInstanceDataPointCollection.html#create/5","title":"CastorEDC.DataCollection.DataPoints.SurveyInstanceDataPointCollection.create/5","type":"function"},{"doc":"Find all collected data points for a specific survey instance [More info]( https://data.castoredc.com/api#/data-points/get_study__study_id__data_points_survey_instance__survey_instance_id _","ref":"CastorEDC.DataCollection.DataPoints.SurveyInstanceDataPointCollection.html#find/4","title":"CastorEDC.DataCollection.DataPoints.SurveyInstanceDataPointCollection.find/4","type":"function"},{"doc":"List all collected data points for all surveys [More info]( https://data.castoredc.com/api#/data-points/get_study__study_id__data_points_survey_instance","ref":"CastorEDC.DataCollection.DataPoints.SurveyInstanceDataPointCollection.html#list/3","title":"CastorEDC.DataCollection.DataPoints.SurveyInstanceDataPointCollection.list/3","type":"function"},{"doc":"Provides access to survey package instance data point collection for all participants","ref":"CastorEDC.DataCollection.DataPoints.SurveyPackageInstanceDataPointCollection.html","title":"CastorEDC.DataCollection.DataPoints.SurveyPackageInstanceDataPointCollection","type":"module"},{"doc":"Create/update a collection of field values for a survey package instance More info","ref":"CastorEDC.DataCollection.DataPoints.SurveyPackageInstanceDataPointCollection.html#create/5","title":"CastorEDC.DataCollection.DataPoints.SurveyPackageInstanceDataPointCollection.create/5","type":"function"},{"doc":"List all collected data points for a survey package instance More info","ref":"CastorEDC.DataCollection.DataPoints.SurveyPackageInstanceDataPointCollection.html#list/4","title":"CastorEDC.DataCollection.DataPoints.SurveyPackageInstanceDataPointCollection.list/4","type":"function"},{"doc":"Provides access to participant related endpoints","ref":"CastorEDC.DataCollection.Participants.html","title":"CastorEDC.DataCollection.Participants","type":"module"},{"doc":"Create a new participant More info","ref":"CastorEDC.DataCollection.Participants.html#create/3","title":"CastorEDC.DataCollection.Participants.create/3","type":"function"},{"doc":"Find a specific participant More info","ref":"CastorEDC.DataCollection.Participants.html#find/3","title":"CastorEDC.DataCollection.Participants.find/3","type":"function"},{"doc":"List all participants More info","ref":"CastorEDC.DataCollection.Participants.html#list/3","title":"CastorEDC.DataCollection.Participants.list/3","type":"function"},{"doc":"Provides access to participant progress related endpoints","ref":"CastorEDC.DataCollection.Participants.Progress.html","title":"CastorEDC.DataCollection.Participants.Progress","type":"module"},{"doc":"List all participant progress More info","ref":"CastorEDC.DataCollection.Participants.Progress.html#list/3","title":"CastorEDC.DataCollection.Participants.Progress.list/3","type":"function"},{"doc":"Provides access to repeating data instance related endpoints","ref":"CastorEDC.DataCollection.Participants.RepeatingDataInstances.html","title":"CastorEDC.DataCollection.Participants.RepeatingDataInstances","type":"module"},{"doc":"Creates a repeating data instance Single instance Multiple instances","ref":"CastorEDC.DataCollection.Participants.RepeatingDataInstances.html#create/4","title":"CastorEDC.DataCollection.Participants.RepeatingDataInstances.create/4","type":"function"},{"doc":"Find a specific repeating data instance More info","ref":"CastorEDC.DataCollection.Participants.RepeatingDataInstances.html#find/4","title":"CastorEDC.DataCollection.Participants.RepeatingDataInstances.find/4","type":"function"},{"doc":"List all repeating data instances More info","ref":"CastorEDC.DataCollection.Participants.RepeatingDataInstances.html#list/4","title":"CastorEDC.DataCollection.Participants.RepeatingDataInstances.list/4","type":"function"},{"doc":"Provides access to survey package instance related endpoints","ref":"CastorEDC.DataCollection.Participants.SurveyPackageInstances.html","title":"CastorEDC.DataCollection.Participants.SurveyPackageInstances","type":"module"},{"doc":"Updates the start time for a survey package instance More info","ref":"CastorEDC.DataCollection.Participants.SurveyPackageInstances.html#patch/5","title":"CastorEDC.DataCollection.Participants.SurveyPackageInstances.patch/5","type":"function"},{"doc":"Provides access to query related endpoints","ref":"CastorEDC.DataCollection.Queries.html","title":"CastorEDC.DataCollection.Queries","type":"module"},{"doc":"Find a specific query More info","ref":"CastorEDC.DataCollection.Queries.html#find/4","title":"CastorEDC.DataCollection.Queries.find/4","type":"function"},{"doc":"List all queries More info","ref":"CastorEDC.DataCollection.Queries.html#list/3","title":"CastorEDC.DataCollection.Queries.list/3","type":"function"},{"doc":"Provides access to randomization related endpoints","ref":"CastorEDC.DataCollection.Randomization.html","title":"CastorEDC.DataCollection.Randomization","type":"module"},{"doc":"Randomize a participant More info","ref":"CastorEDC.DataCollection.Randomization.html#create/3","title":"CastorEDC.DataCollection.Randomization.create/3","type":"function"},{"doc":"Find randomization details of a participant More info","ref":"CastorEDC.DataCollection.Randomization.html#find/3","title":"CastorEDC.DataCollection.Randomization.find/3","type":"function"},{"doc":"Provides access to repeating data instance related endpoints","ref":"CastorEDC.DataCollection.RepeatingDataInstances.html","title":"CastorEDC.DataCollection.RepeatingDataInstances","type":"module"},{"doc":"Find a specific repeating data instance More info","ref":"CastorEDC.DataCollection.RepeatingDataInstances.html#find/3","title":"CastorEDC.DataCollection.RepeatingDataInstances.find/3","type":"function"},{"doc":"List all repeating data instances More info","ref":"CastorEDC.DataCollection.RepeatingDataInstances.html#list/3","title":"CastorEDC.DataCollection.RepeatingDataInstances.list/3","type":"function"},{"doc":"Provides access to statistics related endpoints","ref":"CastorEDC.DataCollection.Statistics.html","title":"CastorEDC.DataCollection.Statistics","type":"module"},{"doc":"Find study statistics More info","ref":"CastorEDC.DataCollection.Statistics.html#find/2","title":"CastorEDC.DataCollection.Statistics.find/2","type":"function"},{"doc":"Provides access to survey package instance related endpoints","ref":"CastorEDC.DataCollection.SurveyPackageInstances.html","title":"CastorEDC.DataCollection.SurveyPackageInstances","type":"module"},{"doc":"Creates a SurveyPackageInstance and (optionally) send the email invite directly. More info","ref":"CastorEDC.DataCollection.SurveyPackageInstances.html#create/3","title":"CastorEDC.DataCollection.SurveyPackageInstances.create/3","type":"function"},{"doc":"Find a specific survey package instance More info","ref":"CastorEDC.DataCollection.SurveyPackageInstances.html#find/3","title":"CastorEDC.DataCollection.SurveyPackageInstances.find/3","type":"function"},{"doc":"List all survey package instances More info","ref":"CastorEDC.DataCollection.SurveyPackageInstances.html#list/3","title":"CastorEDC.DataCollection.SurveyPackageInstances.list/3","type":"function"},{"doc":"Locks/unlocks a SurveyPackageInstance. More info","ref":"CastorEDC.DataCollection.SurveyPackageInstances.html#patch/4","title":"CastorEDC.DataCollection.SurveyPackageInstances.patch/4","type":"function"},{"doc":"Provides access to verification related endpoints","ref":"CastorEDC.DataCollection.Verifications.html","title":"CastorEDC.DataCollection.Verifications","type":"module"},{"doc":"List all verifications More info","ref":"CastorEDC.DataCollection.Verifications.html#list/3","title":"CastorEDC.DataCollection.Verifications.list/3","type":"function"},{"doc":"Provides access to field dependency related endpoints","ref":"CastorEDC.StudyProtocol.FieldDependencies.html","title":"CastorEDC.StudyProtocol.FieldDependencies","type":"module"},{"doc":"Find a specific field dependency More info","ref":"CastorEDC.StudyProtocol.FieldDependencies.html#find/4","title":"CastorEDC.StudyProtocol.FieldDependencies.find/4","type":"function"},{"doc":"List all field dependencies More info","ref":"CastorEDC.StudyProtocol.FieldDependencies.html#list/3","title":"CastorEDC.StudyProtocol.FieldDependencies.list/3","type":"function"},{"doc":"Provides access to field validation related endpoints","ref":"CastorEDC.StudyProtocol.FieldValidations.html","title":"CastorEDC.StudyProtocol.FieldValidations","type":"module"},{"doc":"Find a specific field validation More info","ref":"CastorEDC.StudyProtocol.FieldValidations.html#find/4","title":"CastorEDC.StudyProtocol.FieldValidations.find/4","type":"function"},{"doc":"List all field validations More info","ref":"CastorEDC.StudyProtocol.FieldValidations.html#list/3","title":"CastorEDC.StudyProtocol.FieldValidations.list/3","type":"function"},{"doc":"Provides access to field related endpoints","ref":"CastorEDC.StudyProtocol.Fields.html","title":"CastorEDC.StudyProtocol.Fields","type":"module"},{"doc":"Find a specific field More info","ref":"CastorEDC.StudyProtocol.Fields.html#find/4","title":"CastorEDC.StudyProtocol.Fields.find/4","type":"function"},{"doc":"List all fields More info","ref":"CastorEDC.StudyProtocol.Fields.html#list/3","title":"CastorEDC.StudyProtocol.Fields.list/3","type":"function"},{"doc":"Provides access to form related endpoints within the study context","ref":"CastorEDC.StudyProtocol.Forms.html","title":"CastorEDC.StudyProtocol.Forms","type":"module"},{"doc":"Find a specific form More info","ref":"CastorEDC.StudyProtocol.Forms.html#find/4","title":"CastorEDC.StudyProtocol.Forms.find/4","type":"function"},{"doc":"List all forms More info","ref":"CastorEDC.StudyProtocol.Forms.html#list/3","title":"CastorEDC.StudyProtocol.Forms.list/3","type":"function"},{"doc":"Provides access to metadata related endpoints","ref":"CastorEDC.StudyProtocol.Metadata.html","title":"CastorEDC.StudyProtocol.Metadata","type":"module"},{"doc":"Find specific metadata More info","ref":"CastorEDC.StudyProtocol.Metadata.html#find/4","title":"CastorEDC.StudyProtocol.Metadata.find/4","type":"function"},{"doc":"List all metadata More info","ref":"CastorEDC.StudyProtocol.Metadata.html#list/3","title":"CastorEDC.StudyProtocol.Metadata.list/3","type":"function"},{"doc":"Provides access to metadata type related endpoints","ref":"CastorEDC.StudyProtocol.MetadataTypes.html","title":"CastorEDC.StudyProtocol.MetadataTypes","type":"module"},{"doc":"Find a specific metadata type More info","ref":"CastorEDC.StudyProtocol.MetadataTypes.html#find/4","title":"CastorEDC.StudyProtocol.MetadataTypes.find/4","type":"function"},{"doc":"List all metadata types More info","ref":"CastorEDC.StudyProtocol.MetadataTypes.html#list/3","title":"CastorEDC.StudyProtocol.MetadataTypes.list/3","type":"function"},{"doc":"Provides access to option group related endpoints","ref":"CastorEDC.StudyProtocol.OptionGroups.html","title":"CastorEDC.StudyProtocol.OptionGroups","type":"module"},{"doc":"Find a specific option group More info","ref":"CastorEDC.StudyProtocol.OptionGroups.html#find/4","title":"CastorEDC.StudyProtocol.OptionGroups.find/4","type":"function"},{"doc":"List all option groups More info","ref":"CastorEDC.StudyProtocol.OptionGroups.html#list/3","title":"CastorEDC.StudyProtocol.OptionGroups.list/3","type":"function"},{"doc":"Provides access to repeating data related endpoints","ref":"CastorEDC.StudyProtocol.RepeatingData.html","title":"CastorEDC.StudyProtocol.RepeatingData","type":"module"},{"doc":"Find a specific repeating data More info","ref":"CastorEDC.StudyProtocol.RepeatingData.html#find/3","title":"CastorEDC.StudyProtocol.RepeatingData.find/3","type":"function"},{"doc":"List all repeating data More info","ref":"CastorEDC.StudyProtocol.RepeatingData.html#list/3","title":"CastorEDC.StudyProtocol.RepeatingData.list/3","type":"function"},{"doc":"Provides access to repeating data form related endpoints","ref":"CastorEDC.StudyProtocol.RepeatingDataForms.html","title":"CastorEDC.StudyProtocol.RepeatingDataForms","type":"module"},{"doc":"Find a specific repeating data form More info","ref":"CastorEDC.StudyProtocol.RepeatingDataForms.html#find/5","title":"CastorEDC.StudyProtocol.RepeatingDataForms.find/5","type":"function"},{"doc":"List all repeating data forms More info","ref":"CastorEDC.StudyProtocol.RepeatingDataForms.html#list/4","title":"CastorEDC.StudyProtocol.RepeatingDataForms.list/4","type":"function"},{"doc":"Provides access to survey form related endpoints","ref":"CastorEDC.StudyProtocol.SurveyForms.html","title":"CastorEDC.StudyProtocol.SurveyForms","type":"module"},{"doc":"Find a specific survey form https://data.castoredc.com/api#/survey-form/get_study__study_id__survey__survey_id__survey_form__survey_form_id_ )","ref":"CastorEDC.StudyProtocol.SurveyForms.html#find/5","title":"CastorEDC.StudyProtocol.SurveyForms.find/5","type":"function"},{"doc":"List all survey forms More info","ref":"CastorEDC.StudyProtocol.SurveyForms.html#list/4","title":"CastorEDC.StudyProtocol.SurveyForms.list/4","type":"function"},{"doc":"Provides access to survey package related endpoints","ref":"CastorEDC.StudyProtocol.SurveyPackages.html","title":"CastorEDC.StudyProtocol.SurveyPackages","type":"module"},{"doc":"Retrieve a single survey package More info","ref":"CastorEDC.StudyProtocol.SurveyPackages.html#find/3","title":"CastorEDC.StudyProtocol.SurveyPackages.find/3","type":"function"},{"doc":"Retrieve list of available survey packages More info","ref":"CastorEDC.StudyProtocol.SurveyPackages.html#list/3","title":"CastorEDC.StudyProtocol.SurveyPackages.list/3","type":"function"},{"doc":"Provides access to survey related endpoints","ref":"CastorEDC.StudyProtocol.Surveys.html","title":"CastorEDC.StudyProtocol.Surveys","type":"module"},{"doc":"Find a specific survey More info","ref":"CastorEDC.StudyProtocol.Surveys.html#find/3","title":"CastorEDC.StudyProtocol.Surveys.find/3","type":"function"},{"doc":"List all surveys More info","ref":"CastorEDC.StudyProtocol.Surveys.html#list/3","title":"CastorEDC.StudyProtocol.Surveys.list/3","type":"function"},{"doc":"Provides access to visit related endpoints","ref":"CastorEDC.StudyProtocol.Visits.html","title":"CastorEDC.StudyProtocol.Visits","type":"module"},{"doc":"Find a specific visit More info","ref":"CastorEDC.StudyProtocol.Visits.html#find/4","title":"CastorEDC.StudyProtocol.Visits.find/4","type":"function"},{"doc":"List all visits More info","ref":"CastorEDC.StudyProtocol.Visits.html#list/3","title":"CastorEDC.StudyProtocol.Visits.list/3","type":"function"},{"doc":"# ## Fix for the free tier of Fly.io livebook # ## Allocate 2GB swap # System.cmd(&quot;fallocate&quot;, [&quot;-l&quot;, &quot;2G&quot;, &quot;/swap&quot;]) # System.cmd(&quot;chmod&quot;, [&quot;400&quot;, &quot;/swap&quot;]) # System.cmd(&quot;mkswap&quot;, [&quot;/swap&quot;]) # System.cmd(&quot;swapon&quot;, [&quot;/swap&quot;]) Mix . install ( [ { :ex_castor_edc , &quot;~&gt; 0.4.0&quot; } , { :kino , &quot;~&gt; 0.6.1&quot; } ] )","ref":"getting_started.html","title":"Using the Castor EDC API","type":"extras"},{"doc":"This notebook serves as an introduction on how to use the API wrapper. It's not meant to be an exhaustive guide.","ref":"getting_started.html#introduction","title":"Using the Castor EDC API - Introduction","type":"extras"},{"doc":"Before we can start making requests to the API we need to have a client_id and a client_secret . You can get this information from the account settings page . Enter your client_id and client_secret in the form below after evaluating the code-block. endpoints = [ { &quot;https://data.castoredc.com/&quot; , &quot;NL&quot; } , { &quot;https://uk.castoredc.com/&quot; , &quot;UK&quot; } , { &quot;https://us.castoredc.com/&quot; , &quot;US&quot; } , { &quot;https://au.castoredc.com/&quot; , &quot;AU&quot; } ] endpoint = Kino.Input . select ( &quot;Region&quot; , endpoints ) |&gt; Kino . render ( ) client_id = Kino.Input . text ( &quot;Client Id&quot; ) |&gt; Kino . render ( ) client_secret = Kino.Input . password ( &quot;Client Secret&quot; ) |&gt; Kino . render ( ) Kino . nothing ( ) Next we need to exchange your client_id and client_secret for an access token. The access token can then be used to make other requests to the API. client = CastorEDC.Client . new ( %{ client_id : Kino.Input . read ( client_id ) , client_secret : Kino.Input . read ( client_secret ) } , endpoint : Kino.Input . read ( endpoint ) ) { :ok , client } = client |&gt; CastorEDC . authenticate ( ) client","ref":"getting_started.html#authentication","title":"Using the Castor EDC API - Authentication","type":"extras"},{"doc":"Let's start at the beginning and fetch all of the studies that you have access to with your account. All function calls return a 3 element tuple. The first element is the http status code, the second element is the decoded response from the API, and the last element is the raw response that came back from the server. We'll make extensive use of pattern-matching to collect that the data that we're interested in, while ignoring the rest. Most API calls support pagination but we'll mostly focus on the first page of the results. If you want to fetch the second page it's possible to pass the page number as a keyword option e.g. page: 2 { 200 , %{ &quot;_embedded&quot; =&gt; %{ &quot;study&quot; =&gt; studies } } , _ } = CastorEDC.Common.Studies . list ( client ) studies Now that we have a list of all the studies we'll need to pick one to dig deeper into with further API requests. studies = studies |&gt; Enum . map ( &amp; { &amp;1 [ &quot;study_id&quot; ] , &amp;1 [ &quot;name&quot; ] } ) |&gt; Enum . sort ( fn { _ , a } , { _ , b } -&gt; a &lt;= b end ) study_id = Kino.Input . select ( &quot;Select a study&quot; , studies ) Let's read the chosen study into an easily accessible variable that we can reuse with other requests. study_id = Kino.Input . read ( study_id )","ref":"getting_started.html#performing-authenticated-api-requests","title":"Using the Castor EDC API - Performing authenticated API requests","type":"extras"},{"doc":"With a study id in our hands we can start digging, let's start with finding out which sites the study is being conducted at! You'll get the option to also run write calls against the API. Make sure that you've chosen a test site as to not put data where it doesn't belong. { 200 , %{ &quot;_embedded&quot; =&gt; %{ &quot;sites&quot; =&gt; sites } } , _ } = CastorEDC.Common.Sites . list ( client , study_id ) sites = sites |&gt; Enum . filter ( &amp; ( &amp;1 [ &quot;deleted&quot; ] == false ) ) |&gt; Enum . map ( &amp; { &amp;1 [ &quot;id&quot; ] , &amp;1 [ &quot;name&quot; ] } ) site_id = Kino.Input . select ( &quot;Choose your test site&quot; , sites ) site_id = Kino.Input . read ( site_id )","ref":"getting_started.html#sites","title":"Using the Castor EDC API - Sites","type":"extras"},{"doc":"The CastorEDC.Participants module is our gateway into fetching information about our participants. We can either fetch entire lists or fetch specific ones. With the create function we can even directly create new ones in our study. Let's start with fetching the first 10. { 200 , %{ &quot;_embedded&quot; =&gt; %{ &quot;participants&quot; =&gt; participants } } , _ } = CastorEDC.DataCollection.Participants . list ( client , study_id , page_size : 10 ) participants As you can see we now have a list of all the participants enrolled in the the study. Let's take the first one from the list and find out more about it. [ %{ &quot;id&quot; =&gt; participant_id } | _ ] = participants { 200 , participant , _ } = CastorEDC.DataCollection.Participants . find ( client , study_id , participant_id ) participant It's also possible to create new Participants via the API allowing for the enrollment of participants through external systems. Before you evaluate the code-block below double-check the selected site, you also need participant creation permission for the given site. { 201 , new_participant , _ } = CastorEDC.DataCollection.Participants . create ( client , study_id , %{ site_id : site_id } ) new_participant","ref":"getting_started.html#participants","title":"Using the Castor EDC API - Participants","type":"extras"},{"doc":"It's also possible to fetch the elements { 200 , %{ &quot;_embedded&quot; =&gt; %{ &quot;visits&quot; =&gt; visits } } , _ } = CastorEDC.StudyProtocol.Visits . list ( client , study_id ) visits |&gt; Enum . sort ( &amp; ( &amp;1 [ &quot;phase_order&quot; ] &lt;= &amp;2 [ &quot;phase_order&quot; ] ) ) { 200 , %{ &quot;_embedded&quot; =&gt; %{ &quot;forms&quot; =&gt; forms } } , _ } = CastorEDC.StudyProtocol.Forms . list ( client , study_id ) forms |&gt; Enum . sort ( &amp; ( &amp;1 [ &quot;step_order&quot; ] &lt;= &amp;2 [ &quot;step_order&quot; ] ) ) { 200 , %{ &quot;_embedded&quot; =&gt; %{ &quot;fields&quot; =&gt; fields } } , _ } = CastorEDC.StudyProtocol.Fields . list ( client , study_id ) fields","ref":"getting_started.html#study-structure","title":"Using the Castor EDC API - Study Structure","type":"extras"},{"doc":"","ref":"getting_started.html#collected-data","title":"Using the Castor EDC API - Collected Data","type":"extras"},{"doc":"Fetching your study data is easy. Remember that this API call is paginated, so you'll need to make multiple API calls to actually get everything. As an example we'll only fetch the first 10 data points on page 1. { 200 , %{ &quot;_embedded&quot; =&gt; %{ &quot;items&quot; =&gt; study_data_points } } , _ } = CastorEDC.DataCollection.DataPoints.StudyDataPointCollection . list ( client , study_id , page : 1 , page_size : 10 ) study_data_points","ref":"getting_started.html#study-data","title":"Using the Castor EDC API - Study Data","type":"extras"},{"doc":"I hope that this notebook has given you a taste of how the library works. The documentation lists all of the available endpoints that you can use.","ref":"getting_started.html#wrapping-up","title":"Using the Castor EDC API - Wrapping up","type":"extras"}]