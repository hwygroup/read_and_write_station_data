load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
    ;"../TEM/SURF_CLI_CHN_MUL_MON-TEM-?????.TXT"
    files   =   systemfunc("ls ../TEM/SURF_CLI_CHN_MUL_MON-TEM-?????.TXT")
    num_files   =   dimsizes(files) 
    start_year  =   1948
    end_year    =   2015
    miss    =   1.0e+5 
    temp        =   new((/num_files,(end_year-start_year+1)*12/),"float",miss)
    time        =   yyyymm_time(start_year,end_year,"integer")
    temp!1      =   "time"
    temp&time   =   time
    temp        =   (/temp@_FillValue/) 
    print(temp@_FillValue)
    printVarSummary(temp)
    
    do k    =   0,  num_files-1
        finame  =   files(k)
        print("finame: "+finame)
        data     =   readAsciiTable(finame, 9, "integer", 0)
        num_time    =   dimsizes(data(:,0))
        do j = 0, num_time-1
            alt0    =   0.1*data(j,3)
            date0   =   data(j,4)*100+data(j,5)
            tem0    =   data(j,6)*0.1
            if (alt0 .lt. 3000.0 .and. tem0 .lt. 200.0) then
                temp(k,{date0}) = tem0
            end if
            ;print(temp(k,{date0}))
            ;print(alt0)
            ;print(date0)
            ;print(tem0)
        end do
        delete(data)
    end do
    
    system("rm -rf temp_1948_2015.nc")
    fi_out  =   addfile("temp_1948_2015.nc","c")
    fi_out->temp    =   temp


end
