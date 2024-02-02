#include <eosio/asset.hpp>
#include <eosio/eosio.hpp>
#include <string>

#include "mulsign_db.hpp"
#include "amax.token.hpp"

namespace amax {

#define CHECKC(exp, code, msg) \
    { if (!(exp)) eosio::check(false, string("$$$") + to_string((int)code) + string("$$$ ") + msg); }

#define COLLECTFEE(from, to, quantity) \
    {	mulsign::collectfee_action act{ _self, { {_self, active_perm} } };\
			act.send( from, to, quantity );}

#define SETMULSIGNM(wallet_id, mulsignm) \
    {	mulsign::setmulsignm_action act{ _self, { {_self, active_perm} } };\
			act.send( _self, wallet_id, mulsignm );}

#define SETMULSIGNER(wallet_id, mulsigner, weight) \
    {	mulsign::setmulsigner_action act{ _self, { {_self, active_perm} } };\
			act.send( _self, wallet_id, mulsigner, weight );}

#define DELMULSIGNER(wallet_id, mulsigner) \
    {	mulsign::delmulsigner_action act{ _self, { {_self, active_perm} } };\
			act.send( _self, wallet_id, mulsigner );}

using std::string;
using namespace eosio;
using namespace wasm::db;

enum class err: uint8_t {
    NONE                 = 0,
    RECORD_NOT_FOUND     = 1,
    RECORD_EXISTING      = 2,
    STATUS_ERROR         = 3,
    SYMBOL_MISMATCH      = 4,
    PARAM_ERROR          = 5,
    PAUSED               = 6,
    NO_AUTH              = 7,
    NOT_POSITIVE         = 8,
    NOT_STARTED          = 9,
    OVERSIZED            = 10,
    TIME_EXPIRED         = 11,
    NOTIFY_UNRELATED     = 12,
    ACTION_REDUNDANT     = 13,
    ACCOUNT_INVALID      = 14,
    FEE_INSUFFICIENT     = 15,
    FIRST_CREATOR        = 16

};

class [[eosio::contract("amax.mulsign")]] mulsign : public contract {
public:
    using contract::contract;

    mulsign(eosio::name receiver, eosio::name code, datastream<const char*> ds):
      _db(_self), contract(receiver, code, ds), _global(_self, _self.value) {
      if (_global.exists()) {
         _gstate = _global.get();

      } else { // first init
         _gstate = global_t{};
      }
    }

    ~mulsign() { _global.set( _gstate, get_self() ); }


    ACTION init(const name& fee_collector, const asset& wallet_fee);

    ACTION setfee(const uint64_t& wallet_id, const asset& wallet_fee);

    /**
     * @brief add a mulsinger into a target wallet, must add all mulsigners within 24 hours upon creation
     * @param issuer
     * @param wallet_id
     * @param mulsigner
     *
     */
    ACTION setmulsigner(const name& issuer, const uint64_t& wallet_id, const name& mulsigner, const uint32_t& weight);

    /**
     * @brief set m value of a mulsign wallet
     * @param issuer
     * @param wallet_id
     * @param mulsignm
     *
     */
    ACTION setmulsignm(const name& issuer, const uint64_t& wallet_id, const uint32_t& mulsignm);

    /**
    * @brief set proposal expiry time in seconds for a given wallet
     * @param issuer - wallet owner only
     * @param wallet_id
     * @param expiry_sec - expiry time in seconds for wallet proposals
     *
     */
    ACTION setproexpiry(const name& issuer, const uint64_t& wallet_id, const uint64_t& expiry_sec) ;


     /**
     * @brief only an existing mulsign can remove him/herself from the mulsingers list
     *        or wallet owner can remove it within 24 hours
     * @param issuer
     * @param wallet_id
     * @param mulsigner
     *
     */
    ACTION delmulsigner(const name& issuer, const uint64_t& wallet_id, const name& mulsigner);
   
     /**
     * @brief lock amount into mulsign wallet, memo: $bank:$walletid
     *
     * @param from
     * @param to
     * @param quantity
     * @param memo: 1) create:$title:$initweight; 2) lock:$wallet_id
     */
    [[eosio::on_notify("*::transfer")]]
    void ontransfer(const name& from, const name& to, const asset& quantity, const string& memo) ;

    /**
     * @brief fee collect action
     *
     */
    ACTION collectfee(const name& from, const name& to, const asset& quantity);
   

    ACTION proposeact(const name& issuer, 
                    const uint64_t& wallet_id, 
                    const action& execution, 
                    const string& excerpt, 
                    const string& description,
                    const uint32_t& duration);

    /**
     * @brief mulsigner can propose an action
     *
     * @param issuer
     * @param wallet_id
     * @param type   mulsign wallet operation: include 'transfer','setmulsignm','setmulsigner','delmulsigner'
     * @param params operation's params, settings with string: 
     *               transfer: name from, name to, asset quantity, memo, contract
     *               setmulsignm: uint8_t mulsignm
     *               setmulsigner: name mulsigner, uint8_t weight
     *               delmulsigner: name mulsigner
     * @param excerpt proposal title
     * @param description proposal detail, start with http/https for a url
     * @param duration proposal duration, should less than wallet expire time
     */
    ACTION propose(const name& issuer, 
                   const uint64_t& wallet_id, 
                   const name& action_name,
                   const name& action_account,
                   const std::vector<char>& packed_action_data, //map string-string,
                   const string& excerpt, 
                   const string& description,
                   const uint32_t& duration);

     /**
      * @brief cancel a proposal before it expires
      *
      */
    ACTION cancel(const name& issuer, const uint64_t& proposal_id);
   
     /**
      * @brief only mulsigner can response the proposal: the m-th of n mulsigner will trigger its execution
      * @param issuer
      * @param proposal_id
      * @param vote 0, against; 1, approve
      */
    ACTION respond(const name& issuer, const uint64_t& proposal_id, uint8_t vote);

    /**
     * @brief execute a proposal action
     * 
     * @param issuer 
     * @param proposal_id 
     */
    ACTION execute(const name& issuer, const uint64_t& proposal_id) ;

    using collectfee_action = eosio::action_wrapper<"collectfee"_n, &mulsign::collectfee>;
    using setmulsignm_action = eosio::action_wrapper<"setmulsignm"_n, &mulsign::setmulsignm>;
    using setmulsigner_action = eosio::action_wrapper<"setmulsigner"_n, &mulsign::setmulsigner>;
    using delmulsigner_action = eosio::action_wrapper<"delmulsigner"_n, &mulsign::delmulsigner>;
    
private:
    dbc                 _db;
    global_singleton    _global;
    global_t            _gstate;
    
    void _create_wallet(const name& creator, const string& title, const uint32_t& wight);
    void _lock_funds(const uint64_t& wallet_id, const name& bank_contract, const asset& quantity);
    void _check_proposal_params(const wallet_t& wallet, const action& execution);
    void _execute_proposal(wallet_t& wallet, proposal_t &proposal);
};
}