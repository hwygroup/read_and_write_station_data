load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
    fi  =   addfile("temp_1948_2015.nc","r")
    temp    =   fi->temp
    printVarSummary(temp)
    time    =   temp&time
    miss    =   temp@_FillValue
    temp    =   where(ismissing(temp) .or. temp .lt. -10000.0, temp@_FillValue,temp)
    printMinMax(temp,0)

    temp_time   =   dim_avg_n_Wrap(temp,0)
    ;printVarSummary(temp_time)
    ;print(temp_time)
    ;exit

    num_time    =   dimsizes(time)
    num_stat    =   dimsizes(temp(:,0))
    print(num_stat)
    
    ref_temp    =   temp(:,{196001})
    do j = 0, num_time-1
        temp(:,j) = where(ismissing(ref_temp), ref_temp,temp(:,j))
    end do


    do j = 0, num_time-1
        count   =   0
        do jj = 0, num_stat-1
            if (.not. ismissing(temp(jj,j)).and. temp(jj,j) .gt. -1000.0) then
                count   =   count+1
            end if
        end do
        print("time: "+time(j)+ " counts: "+count)
        ;delete(inds)
    end do

    temp_time   =   dim_avg_n_Wrap(temp,0)
    printVarSummary(temp_time)
    print(temp_time)
    temp_196001_201312  =   temp_time({196001:201312})
    system("rm -rf temp_196001_201312.nc")
    fi_out  =   addfile("temp_196001_201312.nc","c")
    fi_out->temp    =   temp_196001_201312 


    tas_ts_nocycle  =   rmAnnCycle1D(temp_196001_201312)
    num_time    =   dimsizes(temp_196001_201312)
    num_years   =   num_time/12
    dec_ts  =   new(num_years-1,"float")
    jan_ts  =   new(num_years-1,"float")
    feb_ts  =   new(num_years-1,"float")
    diff1   =   new(num_years-1,"float")
    diff2   =   new(num_years-1,"float")
    diff3   =   new(num_years-1,"float")

    do k = 0, num_years-2
        dec_ts(k) = tas_ts_nocycle(k*12+11)
        jan_ts(k) = tas_ts_nocycle(k*12+12)
        feb_ts(k) = tas_ts_nocycle(k*12+13)
        diff1(k)  = tas_ts_nocycle(k*12+12) - tas_ts_nocycle(k*12+11)
        diff2(k)  = tas_ts_nocycle(k*12+13) - tas_ts_nocycle(k*12+12)
        diff3(k)  = tas_ts_nocycle(k*12+14) - tas_ts_nocycle(k*12+13)
    end do


    system("rm -f rapid.nc")
    fi_out  =   addfile("rapid.nc","c")
    fi_out->dec_ts  =   dec_ts
    fi_out->jan_ts  =   jan_ts
    fi_out->feb_ts  =   feb_ts
    fi_out->diff1   =   diff1
    fi_out->diff2   =   diff2
    fi_out->diff3   =   diff3


end
