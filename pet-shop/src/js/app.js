App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    // Load pets.
    $.getJSON('../pets.json', function(data) {
      var petsRow = $('#petsRow');
      var petTemplate = $('#petTemplate');

      for (i = 0; i < data.length; i ++) {
        petTemplate.find('.panel-title').text(data[i].name + ' ' + i);
        petTemplate.find('img').attr('src', data[i].picture);
        petTemplate.find('.pet-breed').text(data[i].breed);
        petTemplate.find('.pet-age').text(data[i].age);
        petTemplate.find('.pet-location').text(data[i].location);
        petTemplate.find('.btn-adopt').attr('data-id', data[i].id);

        petsRow.append(petTemplate.html());
      }
    });

    return App.initWeb3();
  },

  initWeb3: function() {
    //  Check for an injected web3 instance.
    if (typeof web3 !== undefined) {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fallback to TestRPC.
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('Adoption.json', function (data) {
      console.log('init contract', data)
      // Get the contract artifact file and instantiate with Truffle contract.
      var AdoptionArtifact = data;
      App.contracts.Adoption = TruffleContract(AdoptionArtifact);

      // Set the provider for our contract.
      App.contracts.Adoption.setProvider(App.web3Provider);

      // Use our contract to retrieve and mark the adopted pets.
      return App.markAdopted();
    })

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '.btn-adopt', App.handleAdopt);
  },

  markAdopted: function(adopters, account) {
    App.contracts.Adoption.deployed()
      .then(function (instance) {
        // Read the adopters array from network.
        return instance.getAdopters.call();
      })
      .then(function (adopters) {
        adopters.map(function (adopter, i) {
          console.log(i, adopter);
          if (adopter !== '0x0000000000000000000000000000000000000000') {
            $('.panel-pet').eq(i).find('button').text('Success').attr('disabled', true);
          }
        })
      })
      .catch(function (err) {
        console.log(err.message);
      });
  },

  handleAdopt: function() {
    event.preventDefault();

    var petId = parseInt($(event.target).data('id'));

    web3.eth.getAccounts(function (error, accounts) {
      if (error) {
        console.log(error);
      }
      var account = accounts[0];
      App.contracts.Adoption.deployed()
        .then(function (instance) {
          return instance.adopt(petId, { from: account });
        })
        .then(function (result) {
          return App.markAdopted();
        })
        .catch(function (err) {
          console.log(err.message);
        });
    });
  }

};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
