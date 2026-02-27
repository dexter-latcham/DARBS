{
  ...
}: {
  services.kanshi = {
    enable = true;
    systemdTarget = "dwl-session.target";
    profiles = {
      desk = {
        outputs =[
          {
            criteria = "Iiyama North America PL2770H 0x00000745";
            mode = "1920x1080@60";
            position = "-1920,0";
            scale = 1.0;
            status = "enable";
          }
          {
            criteria = "Iiyama North America PL3467WQ 1214232301137";
            mode = "3440x1440@165";
            position = "0,0";
            scale = 1.5;
            status = "enable";
          }
          {
            criteria = "Chimei Innolux Corporation 0x1521 Unknown";
            status = "disable";
          }
        ];
      };
      laptop = {
          outputs = [
            {
              criteria = "Chimei Innolux Corporation 0x1521 Unknown";
              mode = "1920x1080@144";
              position = "0,0";
              scale = 1.0;
              status = "enable";
            }
          ];
      };
    };
  };
}
