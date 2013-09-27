pro exit_on_error

catch,error_status
if error_status ne 0 then begin
        print,'Error index: ', error_status
        print,'Exiting IDL'
        exit
endif

end
