// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

(function($) {
  this.replace_id = function replace_id(s) {
    var new_id = new Date().getTime();
    return s.replace(/NEW_RECORD/g, new_id);
  };
  
  this.setupMultiFields = function (objName, formTemplate) {
    $('.delete_' + objName + '_field').hide().each(function () {
      var $checkbox = $(this).find('input[type="checkbox"]');
      $(this).after('<a class="delete_icon delete_' + objName +
        '" rel="' + $checkbox.attr('id') + '" href="#">Delete</a>');
    });
    
    $('button#add_' + objName).click(function () {
      $('#' + objName + '_collection').append(replace_id(formTemplate));
      return false;
    });
    
    $('a.delete_' + objName).click(function () {
        var al = confirm('Are you sure?')
      var rel = $(this).attr('rel');
     if (al){
     $('#' + rel).attr('checked', true);
      $(this).parent('div.' + objName).hide();
      $(this).hide();
    }
      return false;
    });        
  };
  
  $.fn.replyList = function() {
    return this.each(function() {
      var $container = $(this);
    
      var $link = $container.prev("p").find("a.reply_toggle");
      var $replies = $container.find("li");
      var $textarea = $container.find("textarea");

      if ($replies.size() > 0) {
        $link.click(function() {
            
          $textarea.focus();
          return false;
        });
      } else {
        $container.hide();
       var to = false;
        $link.click(function() {
            
            if(to== false){
          $container.show();
          to = true;
            }
            else{
               $container.hide();
                to = false;
            }
           
          $textarea.focus();
     
          return false;
        });
      }
    });
  };

  $(document).ready(function () {
    $('.not_implemented').fadeTo(0, 0.75);
    $('.not_implemented *').css('cursor', 'wait');
    
    $('.not_implemented a, a.TODO').click(function () {
      alert("This functionality is not yet implemented.");
      return false;
    });
    
    $('.promo a').attr('target', '_blank');

    $(".search_terms").focus(function() {$(this).val("");});

    $("#user_search").focus(function() {
      $(this).val("");
    })
    .autocomplete({
      ajax: "/profiles",
      match: function(typed) {return true;}
    })
    .parents("form").submit(function() {      
      $.post(this.action, $(this).serialize(), function(src) {      
        var $li = $(src).hide();
        $("#user_search").val("");
        $("#project_members").append($li);
        $li.fadeIn();
      });

      return false;
    });

    $("div.replies").replyList();

    $("a[rel=facebox]").facebox();

    $(this).bind('reveal.facebox', function() {
      Recaptcha.create(recaptcha_public_key, document.getElementById('dynamic_recaptcha'));
    });

    $("a.show_all_updates").click(function() {
      $link = $(this);

      $.get(this.href, function(src) {
        $("div#updates ul").append($(src));
      });

      $link.fadeOut();
      return false;
    });

    $("ul.project_filter").each(function() {
      var $links = $(this).find("a");
      var $content = $("div#my_projects > div");

      $links.click(function() {
        $links.removeClass("active");
        $(this).addClass("active");

        var section = this.href.split("#")[1];

        if ($.inArray(section, ["originated", "collaborating", "following"]) != -1) {
          $content.hide();
          $("div." + section).show();
        } else {
          $content.show();
        }

        return false;
      });

      $(this).find("." + location.hash.split("#")[1]).click();
    });

    $("input#invite_request_project").each(function() {
      if (!this.checked) {
        $("#description_container").hide();
      }

      $(this).click(function() {
        if (this.checked) {
          $("#description_container").show();
        } else {
          $("#description_container").hide();
        }
      });
    });
  });
})(jQuery);



function origin_new(id){

    //if(id==""){
      //  return false
    //}

    //loader.prependTo("#lookupdiv")
    jQuery.ajax({
        type: "GET",
        url: "/accesses/originated",
        dataType: 'script',
        data: {
            'id' : id
        },
        success: function(){
            loader.remove();
        }
    });
}

function origin_new_request(id){

    //if(id==""){
      //  return false
    //}

    //loader.prependTo("#lookupdiv")
    jQuery.ajax({
        type: "GET",
        url: "/accesses/originated_open",
        dataType: 'script',
        data: {
            'id' : id
        },
        success: function(){
            loader.remove();
        }
    });
}







function collab_new(id){

    //if(id==""){
      //  return false
    //}

    //loader.prependTo("#lookupdiv")
    jQuery.ajax({
        type: "GET",
        url: "/accesses/collaborators",
        dataType: 'script',
        data: {
            'id' : id
        },
        success: function(){
            loader.remove();
        }
    });
}

function collab_new_request(id){

    //if(id==""){
      //  return false
    //}

    //loader.prependTo("#lookupdiv")
    jQuery.ajax({
        type: "GET",
        url: "/accesses/collaborators_open",
        dataType: 'script',
        data: {
            'id' : id
        },
        success: function(){
            loader.remove();
        }
    });
}







function follow_new_request(id){

    //if(id==""){
      //  return false
    //}

    //loader.prependTo("#lookupdiv")
    jQuery.ajax({
        type: "GET",
        url: "/accesses/follow_open",
        dataType: 'script',
        data: {
            'id' : id
        },
        success: function(){
            loader.remove();
        }
    });
}

function message_settings(id){

    //if(id==""){
      //  return false
    //}

    //loader.prependTo("#lookupdiv")
   
    jQuery.ajax({
        type: "GET",
        url: "/accesses/message_settings",
        dataType: 'script',
        data: {
            'id' : id
        },
        success: function(){
            loader.remove();
        }
    });
}


function account_settings(id){

     jQuery.ajax({
        type: "GET",
        url: "/accesses/account_settings",
        dataType: 'script',
        data: {
            'id' : id
        },
        success: function(){
            loader.remove();
        }
    });
}

function permission_granted() {
  $('fb_publish').childElements().each(function(item){
    item.remove();
  });
  new Ajax.Request('/welcome/fbpublish', {method: 'get'})
}

function populate_date(month, day, year) {
  ge('date_month').value = month;
  ge('date_day').value = day;
  ge('date_year').value = year;
}

function ge(elem) {
  return document.getElementById(elem);
}

/*
 * Ensure Facebook app is initialized and call callback afterward
 *
 */
function ensure_init(callback) {
  if(!window.api_key) {
    window.alert("api_key is not set");
  }

  if(window.is_initialized) {
    callback();
  } else {
    FB_RequireFeatures(["XFBML", "CanvasUtil"], function() {
        FB.FBDebug.logLevel = 4;
        FB.FBDebug.isEnabled = true;
        // xd_receiver.php is a relative path here, because The Run Around
        // could be installed in a subdirectory
        // you should prefer an absolute URL (like "/xd_receiver.php") for more accuracy
        FB.Facebook.init(window.api_key, window.xd_receiver_location);

        window.is_initialized = true;
        callback();
      });
  }
}

/*
 * "Session Ready" handler. This is called when the facebook
 * session becomes ready after the user clicks the "Facebook login" button.
 * In a more complex app, this could be used to do some in-page
 * replacements and avoid a full page refresh. For now, just
 * notify the server the user is logged in, and redirect to home.
 *
 * @param link_to_current_user  if the facebook session should be
 *                              linked to a currently logged in user, or used
 *                              to create a new account anyway
 */
function facebook_button_onclick() {

  ensure_init(function() {
      FB.Facebook.get_sessionState().waitUntilReady(function() {
          var user = FB.Facebook.apiClient.get_session() ?
            FB.Facebook.apiClient.get_session().uid :
            null;

          // probably should give some indication of failure to the user
          if (!user) {
            return;
          }

          // The Facebook Session has been set in the cookies,
          // which will be picked up by the server on the next page load
          // so refresh the page, and let all the account linking be
          // handled on the server side

          // This could be done a myriad of ways; for a page with more content,
          // you could do an ajax call for the account linking, and then
          // just replace content inline without a full page refresh.
          //refresh_page();
          window.location = window.facebook_authenticate_location;
        });
    });
}

/*
 * Do a page refresh after login state changes.
 * This is the easiest but not the only way to pick up changes.
 * If you have a small amount of Facebook-specific content on a large page,
 * then you could change it in Javascript without refresh.
 */
function refresh_page() {
  window.location = '/';
}

function logout() {
  window.location = '/login/logout';
}

/*
 * Show the feed form. This would be typically called in response to the
 * onclick handler of a "Publish" button, or in the onload event after
 * the user submits a form with info that should be published.
 *
 */
function facebook_publish_feed_story(form_bundle_id, template_data) {
  // Load the feed form
  FB.ensureInit(function() {
          FB.Connect.showFeedDialog(form_bundle_id, template_data);
          //FB.Connect.showFeedDialog(form_bundle_id, template_data, null, null, FB.FeedStorySize.shortStory, FB.RequireConnect.promptConnect);

      // hide the "Loading feed story ..." div
      // ge('feed_loading').style.visibility = "hidden";
  });
}


//STAR RATINGS/form.js HELPERS
function showRequest(formData, jqForm, options) { 
    // formData is an array; here we use $.param to convert it to a string to display it 
    // but the form plugin does this for you automatically when it submits the data 
    var queryString = $.param(formData); 
 
    // jqForm is a jQuery object encapsulating the form element.  To access the 
    // DOM element for the form do this: 
    // var formElement = jqForm[0]; 
 
    alert('About to submit: \n\n' + queryString); 
 
    // here we could return false to prevent the form from being submitted; 
    // returning anything other than false will allow the form submit to continue 
    return true; 
} 

function showResponse(responseText, statusText, xhr, $form)  { 
    // for normal html responses, the first argument to the success callback 
    // is the XMLHttpRequest object's responseText property 
 
    // if the ajaxSubmit method was passed an Options Object with the dataType 
    // property set to 'xml' then the first argument to the success callback 
    // is the XMLHttpRequest object's responseXML property 
 
    // if the ajaxSubmit method was passed an Options Object with the dataType 
    // property set to 'json' then the first argument to the success callback 
    // is the json data object returned by the server 
 
    alert('status: ' + statusText + '\n\nresponseText: \n' + responseText + 
        '\n\nThe output div should have already been updated with the responseText.'); 
} 


