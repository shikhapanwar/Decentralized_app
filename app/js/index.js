// ===========================
// Storage (IPFS) example
// ===========================
document.write('<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>');
document.write('<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script> ');

$(document).ready(function() {
  // EmbarkJS.Storage.setProvider('ipfs',{server: 'localhost', port: '5001'});
  // EmbarkJS.Storage.ipfsConnection.ping()
  //   .then(function(){
  //     console.log("IPFS Connected");
  //   })
  //   .catch(function(err) {
  //     if(err){
  //       console.log("IPFS Connection Error => " + err.message);
  //     }
  // });

            
    

  $("#storage button.setIpfsText").click(function() {
    var value = $("#storage input.ipfsText").val();
    EmbarkJS.Storage.saveText(value).then(function(hash) {
      $("span.textHash").html(hash);
      $("input.textHash").val(hash);
    });
    addToLog("#storage", "EmbarkJS.Storage.saveText('" + value + "').then(function(hash) { })");
  });

  $("#storage button.loadIpfsHash").click(function() {
    var value = $("#storage input.textHash").val();
    EmbarkJS.Storage.get(value).then(function(content) {
      $("span.ipfsText").html(content);
    });
    addToLog("#storage", "EmbarkJS.Storage.get('" + value + "').then(function(content) { })");
  });

  $("#storage button.uploadFile").click(function() {
    var input = $("#storage input[type=file]");
    EmbarkJS.Storage.uploadFile(input).then(function(hash) {
      $("span.fileIpfsHash").html(hash);
      $("input.fileIpfsHash").val(hash);
    });
    addToLog("#storage", "EmbarkJS.Storage.uploadFile($('input[type=file]')).then(function(hash) { })");
  });

  $("#storage button.loadIpfsFile").click(function() {
    var hash = $("#storage input.fileIpfsHash").val();
    var url = EmbarkJS.Storage.getUrl(hash);
    var link = '<a href="' + url + '" target="_blank">' + url + '</a>';
    $("span.ipfsFileUrl").html(link);
    $(".ipfsImage").attr('src', url);
    addToLog("#storage", "EmbarkJS.Storage.getUrl('" + hash + "')");
  });

});

// ===========================
// Communication (Whisper) example
// ===========================
$(document).ready(function() {

  $("#communication .error").hide();
  web3.version.getWhisper(function(err, res) {
    if (err) {
      $("#communication .error").show();
      $("#communication-controls").hide();
+     $("#status-communication").addClass('status-offline');
    } else {
      EmbarkJS.Messages.setProvider('whisper');
      $("#status-communication").addClass('status-online');
    }
  });

  $("#communication button.listenToChannel").click(function() {
    var channel = $("#communication .listen input.channel").val();
    $("#communication #subscribeList").append("<br> subscribed to " + channel + " now try sending a message");
    EmbarkJS.Messages.listenTo({topic: [channel]}).then(function(message) {
      $("#communication #messagesList").append("<br> channel: " + channel + " message: " + message);
    });
    addToLog("#communication", "EmbarkJS.Messages.listenTo({topic: ['" + channel + "']}).then(function(message) {})");
  });

  $("#communication button.sendMessage").click(function() {
    var channel = $("#communication .send input.channel").val();
    var message = $("#communication .send input.message").val();
    EmbarkJS.Messages.sendMessage({topic: channel, data: message});
    addToLog("#communication", "EmbarkJS.Messages.sendMessage({topic: '" + channel + "', data: '" + message + "'})");
  });

});
