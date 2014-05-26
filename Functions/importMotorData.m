function motorData = importMotorData(fileName)
%importMotorData takes motor data from a tab deliminted table and puts it
%in a useful struct

%INPUT - filename string with the file name of a tab-delimited motor data
%file with the following columns - time (ms) Motor1 R, Motor1 L, Motor2
%R,Motor2 L

%OUTPUT
%struct with fields time, M1R, M1L, M2R, M2L
motorData = tdfread(fileName); %motor data from arduino
%create names of new fields
fields = fieldnames(motorData);
oldtime = fields(1);
oldM1R = fields(2);
oldM1L = fields(3);
oldM2R = fields(4);
oldM2L = fields(5);
%create renamed data
motorData.time = motorData.(oldtime{:});
motorData.M1L = motorData.(oldM1L{:});
motorData.M1R = motorData.(oldM1R{:});
motorData.M2L = motorData.(oldM2L{:});
motorData.M2R = motorData.(oldM2R{:});
%get rid of old data
motorData = rmfield(motorData,(oldtime{:}));
motorData = rmfield(motorData,(oldM1L{:}));
motorData = rmfield(motorData,(oldM1R{:}));
motorData = rmfield(motorData,(oldM2L{:}));
motorData = rmfield(motorData,(oldM2R{:}));

end