This file explains the rows of the table command_jobs and it's possible values:

| row name | values | description |
| -------- | ------ | ----------- |
| timestamp |  | timestamp when the job will be executed. |
| payload |  | values that are separated by '#'. |
| state | success; pending; failed; await | State of the job. If a job has the state 'await' and there is a payload, then we are waiting on some trigger action to release this job to be executed. |
| commands_idcommands |  | The id of the command that will be executed. |
| device_iddevice |  | The device. |
