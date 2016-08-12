clear


$rawSpreadSheet = Import-CSV C:\forWebbDiffScriptInfo.csv

$VMs = $rawSpreadSheet | % {$_.NAME} | Get-Unique



$TagCatNames = $rawSpreadSheet| Get-Member | Where {$_.MemberType -eq "NoteProperty"} | Select -Expand Name | Where {$_ -ne "Name"}
#echo $VMs.count


$choice = Read-Host 'Enter choice (1-6 inclusive). See related readme or commented out block in script for description of each command.'
#6. only make changes for the tags that are on the spreadsheet for all VMs
#5. only make changes for specific vm for the tags that are on the spreadsheet.
#4. Commit all changes proposed by spreadsheet (confirmation will follow). 
#3. Enter VM. Commit proposed changes from spreadsheet for that VM.
#2. Enter VM. See current tag and proposed tag from spreadsheet.
#1. View all current tag information and proposed tag information from spreadsheet
if($choice -eq 1){
     for($j=0; $j -le $VMs.count-1; $j++){ #check the minus 1 bullshit
   
        $get_VM = Get-TagAssignment -Entity $VMs[$j] | Select Tag | Format-Table -hidetableheaders
        echo "$($VMs[$j]) has the following tags in their associated categories:"
        echo " "
        for($i=0; $i -le $get_VM.count-1; $i++){ #check the minus 1 bullshit
          echo $get_VM[$i]
        }
        echo " "
        echo "$($VMs[$j]) should have the following tags in their associated categories based on the spreadsheet: "
        echo " "

        for($i=0; $i -le $TagCatNames.count-1; $i++){
          $currentWant = $($TagCatNames[$i])
          #echo $currentWant
          echo "$($TagCatNames[$i])/$($rawSpreadSheet[$j].$currentWant)"
        }

        echo "-------------------------------"

    }

}

elseif($choice -eq 2){
     $desiredVM = Read-Host 'Which VM would you like the information for?'
    
     echo "Here is the information from vCenter"
     $get_VM = Get-TagAssignment -Entity $desiredVM | Select Tag | Format-Table -hidetableheaders

     echo $get_VM

     echo "Here is the information from the spreadsheet:"
     echo ""
     for($j=0; $j -le $VMs.count-1; $j++){ #check the minus 1 bullshit
         for($i=0; $i -le $TagCatNames.count-1; $i++){
              $currentWant = $($TagCatNames[$i])
              #echo $currentWant
              if($VMs[$j] -eq $desiredVM){
                echo "$($TagCatNames[$i])/$($rawSpreadSheet[$j].$currentWant)"
              }
         }
     }
     echo ""

}

elseif($choice -eq 3){
    $desiredVM = Read-Host 'Which VM would you like overwrite based on the spreadsheet?'
    $myVM = Get-VM -Name $desiredVM
    $myTagAssignment = Get-TagAssignment $myVM
    Remove-TagAssignment $myTagAssignment -Confirm:$false

    #now start to write

     for($j=0; $j -le $VMs.count-1; $j++){ #check the minus 1 bullshit
         for($i=0; $i -le $TagCatNames.count-1; $i++){
              $currentWant = $($TagCatNames[$i])
              #echo $currentWant
              if($VMs[$j] -eq $desiredVM){
                #echo "$($TagCatNames[$i])/$($rawSpreadSheet[$j].$currentWant)"
                if (-Not (Get-TagCategory $currentWant -ea SilentlyContinue)) {
                    New-TagCategory -Name $currentWant -Description "$currentWant from CMDB" | Out-Null
                    echo "new category created"
                }
                if (-Not (Get-Tag -Category $currentWant $($rawSpreadSheet[$j].$currentWant) -ea SilentlyContinue)) {
                    New-Tag -Name $($rawSpreadSheet[$j].$currentWant) -Category $currentWant -Description "$($rawSpreadSheet[$j].$currentWant) from CMDB" | Out-Null
                    echo "new tag created"
                }
                echo $($rawSpreadSheet[$j].$currentWant)
                $other =  $($rawSpreadSheet[$j].$currentWant)
                echo $other
                $myTag = Get-Tag -Category $currentWant $($rawSpreadSheet[$j].$currentWant)
                Get-VM -Name $desiredVM | New-TagAssignment -Tag $myTag
              }
         }
     }



}


elseif($choice -eq 4){

$makesure = Read-Host 'This is a confirmation, proceed(y/n)?'

    if($makesure -eq 'y'){

     for($j=0; $j -le $VMs.count-1; $j++){
            $myVM = Get-VM -Name $($VMs[$j])
            $myTagAssignment = Get-TagAssignment $myVM
            Remove-TagAssignment $myTagAssignment -Confirm:$false
     }

     echo "done removal"
       
    for($j=0; $j -le $VMs.count-1; $j++){
        $myVM = Get-VM -Name $($VMs[$j])
        $myTagAssignment = Get-TagAssignment $myVM
        

        for($i=0; $i -le $TagCatNames.count-1; $i++){
            $currentWant = $($TagCatNames[$i])
            # echo "category: $currentWant"
            $other = $($rawSpreadSheet[$j].$currentWant)
            #echo "tag: $other"
                
            if (-Not (Get-TagCategory $currentWant -ea SilentlyContinue)) {
                    New-TagCategory -Name $currentWant -Description "$currentWant from CMDB" | Out-Null
                    echo "new category created"
            }
            
            if (-Not (Get-Tag -Category $currentwant $($rawSpreadSheet[$j].$currentWant) -ea SilentlyContinue)) {
                New-Tag -Name $($rawSpreadSheet[$j].$currentWant) -Category $currentWant -Description "$($rawSpreadSheet[$j].$currentWant) from CMDB" | Out-Null
                echo "new tag created"
            }

                $myTag = Get-Tag -Category $currentWant $other
                echo "my tag: $myTag"
                echo "trying to add $other to $currentwant category for $($VMs[$j])"
                Get-VM -Name $($VMs[$j]) | New-TagAssignment -Tag $myTag
        }
        
    }

   
    }
    else{
        echo "Aborted."
    }
}
elseif($choice -eq 5){

    $desiredVM = Read-Host 'Which VM would you like overwrite the specific categories on the spreadsheet?'
    $myVM = Get-VM -Name $desiredVM
   #$result = Get-TagAssignment -Entity $myVM -Category "Class" | Select Tag | Format-Table -hidetableheaders
   for($i=0; $i -le $TagCatNames.count-1; $i++){
        $currentTag = Get-TagAssignment -Entity $myVM -Category $TagCatNames[$i]# | Select Tag | Format-Table -hidetableheaders
        #echo $currentTag

        Remove-TagAssignment -TagAssignment $currentTag -Confirm:$false

   }

   echo "Relevant Tags removed at this point."

    for($j=0; $j -le $VMs.count-1; $j++){ #check the minus 1 bullshit
         for($i=0; $i -le $TagCatNames.count-1; $i++){
              $currentWant = $($TagCatNames[$i])
              #echo $currentWant
              if($VMs[$j] -eq $desiredVM){
                #echo "$($TagCatNames[$i])/$($rawSpreadSheet[$j].$currentWant)"
                if (-Not (Get-TagCategory $currentWant -ea SilentlyContinue)) {
                    New-TagCategory -Name $currentWant -Description "$currentWant from CMDB" | Out-Null
                    echo "new category created"
                }
                if (-Not (Get-Tag -Category $currentWant $($rawSpreadSheet[$j].$currentWant) -ea SilentlyContinue)) {
                    New-Tag -Name $($rawSpreadSheet[$j].$currentWant) -Category $currentWant -Description "$($rawSpreadSheet[$j].$currentWant) from CMDB" | Out-Null
                    echo "new tag created"
                }
                echo $($rawSpreadSheet[$j].$currentWant)
                $other =  $($rawSpreadSheet[$j].$currentWant)
                echo $other
                $myTag = Get-Tag -Category $currentWant $($rawSpreadSheet[$j].$currentWant)
                Get-VM -Name $desiredVM | New-TagAssignment -Tag $myTag
              }
         }
     }

        
        
    

   

}

elseif($choice -eq 6){
    $continueConfirmation = Read-Host 'This will commit changes to all of the VMs on the spreadsheet. Continue? (y/n)'
    if($continueConfirmation -eq 'y'){
        for($j=0; $j -le $VMs.count-1; $j++){
            $myVM = Get-VM -Name $($VMs[$j])
            
            for($i=0; $i -le $TagCatNames.count-1; $i++){
                $currentTag = Get-TagAssignment -Entity $myVM -Category $TagCatNames[$i]# | Select Tag | Format-Table -hidetableheaders
                #echo $currentTag

                Remove-TagAssignment -TagAssignment $currentTag -Confirm:$false
            }
        }

        for($j=0; $j -le $VMs.count-1; $j++){
        $myVM = Get-VM -Name $($VMs[$j])
        $myTagAssignment = Get-TagAssignment $myVM
        

            for($i=0; $i -le $TagCatNames.count-1; $i++){
                $currentWant = $($TagCatNames[$i])
                # echo "category: $currentWant"
                $other = $($rawSpreadSheet[$j].$currentWant)
                #echo "tag: $other"
                
                if (-Not (Get-TagCategory $currentWant -ea SilentlyContinue)) {
                        New-TagCategory -Name $currentWant -Description "$currentWant from CMDB" | Out-Null
                        echo "new category created"
                }
            
                if (-Not (Get-Tag -Category $currentwant $($rawSpreadSheet[$j].$currentWant) -ea SilentlyContinue)) {
                    New-Tag -Name $($rawSpreadSheet[$j].$currentWant) -Category $currentWant -Description "$($rawSpreadSheet[$j].$currentWant) from CMDB" | Out-Null
                    echo "new tag created"
                }

                    $myTag = Get-Tag -Category $currentWant $other
                    echo "my tag: $myTag"
                    echo "trying to add $other to $currentwant category for $($VMs[$j])"
                    Get-VM -Name $($VMs[$j]) | New-TagAssignment -Tag $myTag
            }
        
        }

    }
    else{
        echo "aborted."
    }
    
}
else{
    echo "Invalid Choice. Restart Script."
}