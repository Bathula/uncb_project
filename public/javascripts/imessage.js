// imessage.js handles ajax submission from modal new message form

//$.noConflict();
var user_names=new Array();

$.ajaxSetup({
    'beforeSend': function(xhr) {
        xhr.setRequestHeader("Accept", "text/javascript")
     }
})


// this does the ajax post and handles the returned data as js - hence "script"
$.fn.submitWithAjax = function() {
    this.submit(function() {
      
        $.post(this.action, $(this).serialize(), null, "script");
       
        return false;
        
    })
    
    return this;
};

// this sets of the form to be submitted with ajax
//
$(document).ready(function() {
    // #new_imessage is form id
   // $("#new_imessage").submitWithAjax();

    var userData = [];

    $(function(){

        //attach autocomplete
        $("#imessage_to_id").autocomplete({

            //define callback to format results
            source: function(req, add){
                                
                //pass request to server
                $.getJSON("/inboxes/api/profiles/search/?", req, function(data) {

                    //create array for response objects
                    var suggestions = [];
                                        
                                        
                    $.each(data, function(i, val){
                       
                        userData[val.profile.id] = val.profile.display_name;
                        suggestions.push(val.profile.display_name);
                    //alert(userData[val.profile.id]);
                    });
                                
                    //pass array to callback
                    add(suggestions);
                //return false;
                });
            },

            //define select handler
            select: function(e, ui) {
                //alert(ui.item.id);
                var _id = $.inArray(ui.item.value, userData);
     
                var _ids = $("#uids").val();
                $("#uids").val(_ids + ':' + _id);
                //alert($("#uids").val());
                //create formatted friend
                                
                var friend = ui.item.value,

                
                span=$('<span class="lftNormal">').html('<span>'+friend+'<a class="remove" href="javascript:" id="'+_id+'" title="Remove '+friend+'">&nbsp;x</a></span>');
                //span = $('<span style="padding-top: 10px; padding-right:10px;">').text(friend),
               
                 for(var k=0;k<user_names.length;k++)
                     {
                         if(user_names[k]==friend)
                             {
                                var element_exist=true;
                             }

                     }
                //add friend to friend div
                if(element_exist!=true)
                    {
                $("#imessage_to_id").val("").css("top", 2);
                span.insertBefore("#imessage_to_id");
                user_names.push(friend);
                    }
                    else
                        {
                            return false;
                        }
                //$("#imessage_to").val("").css("top", 2);
                return false;
            },

            //define select handler
            change: function() {
                //prevent 'to' field being updated and correct position
                $("#imessage_to_id").val("").css("top", 1);
            //$("#imessage_to").val("").css("top", 0);
            }
        });

        //add click handler to friends div
        $("#friends").click(function(){
            //focus 'to' field
            $("#imessage_to_id").focus();
        });

        //add live handler for clicks on remove links
        $(".remove", document.getElementById("friends")).live("click", function(){

             
             var inner_html=$(this).parent().html();
             var inner_html_array=inner_html.split("<");
             var selected_index=$.inArray(inner_html_array[0],user_names);
            
             user_names.splice(selected_index,1);
            
         
         
            var user_ids=$("#uids").val().split(":");
            var output_str="nil";
         
            for(var i=0;i<user_ids.length;i++)
                {
                    
                    if(user_ids[i] != $(this).attr("id"))
                        {
                          output_str=output_str+":"+user_ids[i];
                        }
                }
             
                //document.getElementById("uids").value=output_str;
                $("#uids").val(output_str);
            //remove current friend
            $(this).parent().parent().remove();
            

            //correct 'to' field position
            if($("#friends span").length === 0) {
                $("#imessage_to_id").css("top", 0);
            }
            
            

        });
    });
})