__author__ = "MAXIM Integrated <https://www.maximintegrated.com/>"


K_MODULE_LCM 	= 0x01
K_MODULE_SH 	= 0x02
K_MODULE_PM 	= 0x03
K_MODULE_MM 	= 0x04
K_MODULE_BM 	= 0x05
K_MODULE_TE 	= 0x06
K_MODULE_TS 	= 0x07
K_MODULE_TL 	= 0x08
K_MODULE_CM 	= 0x09
K_MODULE_RCE 	= 0x0a
K_MODULE_COMMON = 0x0b
K_MODULE_PM_EXT = 0x13


ERROR_MSG = x = [['                                                                        ' for i in range(50)] for j in range(20)]

##################################### LCM #########################################
ERROR_MSG[K_MODULE_LCM][1] = "ERR_NOT_INITIALIZED : LCM module not initialized"
ERROR_MSG[K_MODULE_LCM][2] = "ERR_NO_LIFECYCLE : Life Cycle Phase can not be retrieved"
ERROR_MSG[K_MODULE_LCM][3] = "ERR_BAD_LIFECYCLE : Life Cycle action does not match Platform's Life Cycle"
ERROR_MSG[K_MODULE_LCM][4] = "ERR_LIFECYCLE_NO_UP : Life cycle value is not to be updated"
ERROR_MSG[K_MODULE_LCM][5] = "ERR_NO_FTM : This error indicates that no FTM's magic value is OTP"
ERROR_MSG[K_MODULE_LCM][6] = "ERR_NO_JTAG : This error indicates that JTAG is not available"
ERROR_MSG[K_MODULE_LCM][7] = "ERR_FATAL_ERROR : Critical error"
ERROR_MSG[K_MODULE_LCM][8] = "ERR_LIFECYCLE_UPDATE : Life Cycle Phase value has to be updated !!! not really an error"
ERROR_MSG[K_MODULE_LCM][9] = "ERR_UNKNOWN: Generic error for unknown behavior"

##################################### SH #########################################
ERROR_MSG[K_MODULE_SH][1]  = "ERR_NOT_INITIALIZED : SH module not initialized"
ERROR_MSG[K_MODULE_SH][2]  = "ERR_CHKROM_FAILED : ROM verification failed"
ERROR_MSG[K_MODULE_SH][3]  = "ERR_ALARM_RAISED : An alarm has been detected"
ERROR_MSG[K_MODULE_SH][4]  = "ERR_COMP_CV : Check Value computation failed"
ERROR_MSG[K_MODULE_SH][5]  = "ERR_AES_UCL_ECB : UCL's AES ECB computation failure"
ERROR_MSG[K_MODULE_SH][6]  = "ERR_AES_UCL_CBC : Failure of use of UCL for AES"
ERROR_MSG[K_MODULE_SH][7]  = "ERR_UCL_INIT_NOK : UCL initialization failed"
ERROR_MSG[K_MODULE_SH][8]  = "ERR_TRNG_READ : TRN can not be read"
ERROR_MSG[K_MODULE_SH][9]  = "ERR_TRNG_FAILURE: TRNG disfunction "
ERROR_MSG[K_MODULE_SH][10] = "ERR_KEY_FAILURE: Code: Key failure "
ERROR_MSG[K_MODULE_SH][11] = "ERR_KEY_SIGNATURE_FAILURE: Signature check failure"
ERROR_MSG[K_MODULE_SH][12] = "ERR_KEY_MISMATCH: "
ERROR_MSG[K_MODULE_SH][13] = "ERR_PASH_HL_MAGIC_VALUE:No HHA address found, only PASH Magic Value"
ERROR_MSG[K_MODULE_SH][14] = "ERR_PASH_BAD_HHA_ADDR: PASH - HHA's address found not good"
ERROR_MSG[K_MODULE_SH][15] = "ERR_PASH_NO_HHA_MAGIC_VALUE: No HHA Magic Value found"
ERROR_MSG[K_MODULE_SH][16] = "ERR_SHA2_HASH_FAILURE: HASH process failure"
ERROR_MSG[K_MODULE_SH][17] = "ERR_SHA2_VERIF_DIGEST_FAILURE: Digest verification failure"
ERROR_MSG[K_MODULE_SH][18] = "ERR_HASHES_DONT_MATCH: Hash verification failed"
ERROR_MSG[K_MODULE_SH][19] = "ERR_CRCS_DONT_MATCH: CRC verification failed"
ERROR_MSG[K_MODULE_SH][20] = "ERR_DATA_MISMATCH: Data mismatches"
ERROR_MSG[K_MODULE_SH][21] = "ERR_UNKNOWN: Generic error for unknown behavior"

####################################### PM ########################################
ERROR_MSG[K_MODULE_PM][0] = "ERR_NOT_INITIALIZED : PM module not initialized"
ERROR_MSG[K_MODULE_PM][1] = "ERR_NO_PROTOCOL : Wanted protocol does not exist"
# STP errors #
ERROR_MSG[K_MODULE_PM][2] = "ERR_STP_NOT_INITIALIZED : STP can not be initialized"
ERROR_MSG[K_MODULE_PM][3] = "ERR_NO_STP_CMD : No STP command corresponds to this identifier"
ERROR_MSG[K_MODULE_PM][4] = "ERR_NO_SCP_CMD : No SCP command corresponds to this identifier"
ERROR_MSG[K_MODULE_PM][5] = "ERR_STP_BAD_CMD_SEQ : Bad STP command sequence"
ERROR_MSG[K_MODULE_PM][6] = "ERR_STP_TIMEOUT : STP listening window times out"
ERROR_MSG[K_MODULE_PM][7] = "ERR_STP_NO_RWK_MW : No Magic Word read"
# SCP errors #
ERROR_MSG[K_MODULE_PM][8] = "ERR_SCP_NOT_INITIALIZED : SCP can not be initialized"
ERROR_MSG[K_MODULE_PM][9] = "ERR_SCP_NO_MORE_MEMORY : No more space left for SCP "
ERROR_MSG[K_MODULE_PM][10] = "ERR_SCP_NO_TIMEOUT : No timeout value, use ROM code's one"
ERROR_MSG[K_MODULE_PM][11] = "ERR_SCP_NET_WRONG_SYNC_PATTERN : Wrong synchronization pattern"
ERROR_MSG[K_MODULE_PM][12] = "ERR_SCP_WRONG_CHECKSUM : Wrong Checksum"
ERROR_MSG[K_MODULE_PM][13] = "ERR_SCP_WRONG_SEC_LVL"
ERROR_MSG[K_MODULE_PM][14] = "ERR_SCP_WRONG_MODE"
ERROR_MSG[K_MODULE_PM][15] = "ERR_SCP_WRONG_CMD : Received command does not match with platform context"
ERROR_MSG[K_MODULE_PM][16] = "ERR_SCP_WRONG_STRING: Wrong characters string received"
ERROR_MSG[K_MODULE_PM][17] = "ERR_SCP_AUTOBOOT_TIMEOUT_END"
ERROR_MSG[K_MODULE_PM][18] = "ERR_SCP_NETWORK_DOWN"
ERROR_MSG[K_MODULE_PM][19] = "ERR_SCP_NOT_CONNECTED"
ERROR_MSG[K_MODULE_PM][20] = "ERR_SCP_CNX_TIMEOUT"
ERROR_MSG[K_MODULE_PM][21] = "ERR_SCP_NET_WRONG_ADDRESS"
ERROR_MSG[K_MODULE_PM][22] = "ERR_SCP_NET_WRONG_LENGTH"
ERROR_MSG[K_MODULE_PM][23] = "ERR_SCP_NET_DATA_PTR_NULL"
ERROR_MSG[K_MODULE_PM][24] = "ERR_SCP_NET_BAD_CONFIG"
ERROR_MSG[K_MODULE_PM][25] = "ERR_SCP_NET_WRONG_PROFILE"
ERROR_MSG[K_MODULE_PM][26] = "ERR_SCP_NET_WRONG_AUTHENT"
ERROR_MSG[K_MODULE_PM][27] = "ERR_SCP_NET_WRONG_SEQ"
ERROR_MSG[K_MODULE_PM][28] = "ERR_SCP_NET_UNKNOWN"
ERROR_MSG[K_MODULE_PM][29] = "ERR_SCP_BAD_PARAMS"
ERROR_MSG[K_MODULE_PM][30] = "ERR_SCP_CORRUPTED_PARAMS"
ERROR_MSG[K_MODULE_PM][31] = "ERR_SCP_NO_SESSION_ALLOWED : SCP window(s) should not be opened"
ERROR_MSG[K_MODULE_PM][32] = "ERR_SCP_CANT_PROCEEED : Command can not be proceeded"
ERROR_MSG[K_MODULE_PM][33] = "ERR_SCP_PIN_CONFLICT : Stimulus pin conflict"
# SCP Applet errors #
ERROR_MSG[K_MODULE_PM][34] = "ERR_SCP_APLT_NO_SYNC : Synchronization pattern is not present in header"
ERROR_MSG[K_MODULE_PM][35] = "ERR_SCP_APLT_VERSION_MISMATCH : Applet target version does not match ROM code's one"
ERROR_MSG[K_MODULE_PM][36] = "ERR_SCP_APLT_WD_ERROR : an error occurs with WRITE_DATA primitive treatment"
ERROR_MSG[K_MODULE_PM][37] = "ERR_SCP_APLT_CD_ERROR : an error occurs with COMPARE_DATA primitive treatment"
ERROR_MSG[K_MODULE_PM][38] = "ERR_SCP_APLT_ED_ERROR : an error occurs with ERASE_DATA primitive treatment"
ERROR_MSG[K_MODULE_PM][39] = "ERR_SCP_APLT_NO_REGISTERED : No applet registered"
ERROR_MSG[K_MODULE_PM][40] = "ERR_SCP_APLT_NOT_HANDLED : Not handled by applet"
# SCP application command errors #
ERROR_MSG[K_MODULE_PM][41] = "ERR_SCP_APPLI_COMPARE_FAILURE : Compare failed"
# SCP command specific errors #
ERROR_MSG[K_MODULE_PM][42] = "ERR_SCP_OLD_CRK_CANNOT_DOWNGRADE : Cannot downgrade CRK"
ERROR_MSG[K_MODULE_PM][43] = "ERR_SCP_OLD_CRK_WRONG_LENGTH : Input length does not match"
ERROR_MSG[K_MODULE_PM][44] = "ERR_SCP_OLD_CRK_NO_MATCH : Old CRK does not match"
ERROR_MSG[K_MODULE_PM][45] = "ERR_UNKNOWN : Generic error for unknown behavior"

#################################### MM ###########################################
ERROR_MSG[K_MODULE_MM][1] = "ERR_NOT_INITIALIZED : BM module not initialized"
ERROR_MSG[K_MODULE_MM][2] = "ERR_LENGTH_NOT_ALIGNED : Data is not aligned according to memory specification"
ERROR_MSG[K_MODULE_MM][3] = "ERR_ADDRESS_NOT_ALIGNED : Address is not aligned according to memory specification"
ERROR_MSG[K_MODULE_MM][4] = "ERR_NOT_ALLOWED : Memory area is not allowed"
ERROR_MSG[K_MODULE_MM][5] = "ERR_NOT_ACCESSIBLE: Memory is not accessible"
ERROR_MSG[K_MODULE_MM][6] = "ERR_OVERFLOW: Data length is out of memory capacity"
ERROR_MSG[K_MODULE_MM][7] = "ERR_32BITS_PGM_FAILED: 32Bits programming procedure failed"
ERROR_MSG[K_MODULE_MM][8] = "ERR_PGM_FAILED: General programming procedure failed"
ERROR_MSG[K_MODULE_MM][9] = "ERR_128BITS_PGM_FAILED: 128Bits programming procedure failed"
ERROR_MSG[K_MODULE_MM][10] = "ERR_PAGE_ERASE_FAILED: Page erasure failed"
# OTP part #
ERROR_MSG[K_MODULE_MM][11] = "ERR_OTP_PGM_FAILED: OTP programmation failed"
ERROR_MSG[K_MODULE_MM][12] = "ERR_OTP_FAILURE: OTP internal failure"
# Secure NVSRAM part #
ERROR_MSG[K_MODULE_MM][13] = "ERR_AES_GENERATION_FAILED: AES key generation failed"
ERROR_MSG[K_MODULE_MM][14] = "ERR_UNKNOWN : Generic error for unknown behavior"

################################## BM #############################################
ERROR_MSG[K_MODULE_BM][1] = "ERR_NOT_INITIALIZED : BM module not initialized"
ERROR_MSG[K_MODULE_BM][2] = "ERR_NOT_AVAILABLE : Bus is not available"
ERROR_MSG[K_MODULE_BM][3] = "ERR_TX : Bus TX error"
ERROR_MSG[K_MODULE_BM][4] = "ERR_RX: Bus RX error"
ERROR_MSG[K_MODULE_BM][5] = "ERR_CONN_LOST: Bus connection lost"
# GPIO
#
# SPI
ERROR_MSG[K_MODULE_BM][6] = "ERR_SPI_NO_PARAMS:"
# UART
ERROR_MSG[K_MODULE_BM][7] = "ERR_UART_NOT_INITIALIZED: UART can not be intialized"
ERROR_MSG[K_MODULE_BM][8] = "ERR_UART_ERR_NOT_AVAILABLE: Invalid port or UART port not available"
ERROR_MSG[K_MODULE_BM][9] = "ERR_UART_ERR_TX: UART TX error"
ERROR_MSG[K_MODULE_BM][10] = "ERR_UART_ERR_RX: UART RX error"
ERROR_MSG[K_MODULE_BM][11] = "ERR_UART_ERR_IRQ_SET: Interrupt can not be initialized"
# Generic
ERROR_MSG[K_MODULE_BM][12] = "ERR_UNKNOWN : Generic error for unknown behavior"

#################################### TE ###########################################
ERROR_MSG[K_MODULE_TE][1] = "ERR_NOT_INITIALIZED : TE module not initialized"
ERROR_MSG[K_MODULE_TE][2] = "ERR_FAILED : Test failed"
ERROR_MSG[K_MODULE_TE][3] = "ERR_TEST_UNKNOWN : Test Identifier is unknown"
ERROR_MSG[K_MODULE_TE][4] = "ERR_NO_TEST_PATT : No test pattern found to perform test"
ERROR_MSG[K_MODULE_TE][5] = "ERR_NO_RES_PATT: No result pattern found to compare with test result"
ERROR_MSG[K_MODULE_TE][6] = "ERR_LIB_NOT_INIT: Library to test has not been initialized"
ERROR_MSG[K_MODULE_TE][7] = "ERR_TRNG_TEST_FAILURE: TRNG selftest failed"
ERROR_MSG[K_MODULE_TE][8] = "ERR_UNKNOWN: Generic error for unknown behavior"

#################################### TS ###########################################
ERROR_MSG[K_MODULE_TS][1] = "ERR_NOT_INITIALIZED : TS module not initialized"
ERROR_MSG[K_MODULE_TS][2] = "TS_ERR_BUSY"
ERROR_MSG[K_MODULE_TS][3] = "TS_ERR_RUNNING"
ERROR_MSG[K_MODULE_TS][4] = "TS_ERR_UNKNOWN"

#################################### CM ###########################################
ERROR_MSG[K_MODULE_CM][1] = "ERR_NOT_INITIALIZED : CM module not initialized"
ERROR_MSG[K_MODULE_CM][2] = "ERR_NOT_AVAILABLE : Parameter is not available"
ERROR_MSG[K_MODULE_CM][3] = "ERR_CORRUPTED : Parameter is corrupted"
ERROR_MSG[K_MODULE_CM][4] = "ERR_NO_PARAM: Asked parameter does not exist"
ERROR_MSG[K_MODULE_CM][5] = "ERR_BAD_LENGTH : Length of parameters does not match"
ERROR_MSG[K_MODULE_CM][6] = "ERR_LOCK_PARAM : Parameter has been read as OTP LOCK value"
ERROR_MSG[K_MODULE_CM][7] = "ERR_USN_CV_NO_MATCH : USN CV does not match"
ERROR_MSG[K_MODULE_CM][8] = "ERR_PARAM_INVALID_OP : Operation on parameter is invalid"
ERROR_MSG[K_MODULE_CM][9] = "ERR_PARAM_NO_OP : Operation on parameter is not needed"
ERROR_MSG[K_MODULE_CM][10] = "ERR_PARAM_BAD_VALUE : Value of parameter is not appropriated"
ERROR_MSG[K_MODULE_CM][11] = "ERR_CANT_PROCEED : Command can not be executed"
ERROR_MSG[K_MODULE_CM][12] = "ERR_CANT_READ_INFOBLOCK : Can not read info block"
ERROR_MSG[K_MODULE_CM][13] = "ERR_NOT_RELEVANT : Not relevant"
ERROR_MSG[K_MODULE_CM][14] = "ERR_UNKNOWN : Generic error for unknown behavior"

#################################### TL ###########################################
#

####################################### RCE #######################################
ERROR_MSG[K_MODULE_RCE][1] = "ERR_NOT_INITIALIZED : RCE module not initialized"
ERROR_MSG[K_MODULE_RCE][2] = "ERR_NO_H_MV : Header magic value not found"
ERROR_MSG[K_MODULE_RCE][3] = "ERR_BAD_SIGNATURE : Digital signature does not match"
ERROR_MSG[K_MODULE_RCE][4] = "ERR_BAD_LA : Bad load address"
ERROR_MSG[K_MODULE_RCE][5] = "ERR_BAD_BIN_LENGTH : Bad binary length"
ERROR_MSG[K_MODULE_RCE][6] = "ERR_BAD_KEY_SIZE : Bad key size"
ERROR_MSG[K_MODULE_RCE][7] = "ERR_BAD_KEY_ID : Bad key Id"
ERROR_MSG[K_MODULE_RCE][8] = "ERR_BAD_KEY_SIGN_MISMATCH : Key length & signature length mismatch"
ERROR_MSG[K_MODULE_RCE][9] = "ERR_BAD_FORMAT : Binary format is not respected"
ERROR_MSG[K_MODULE_RCE][10] = "ERR_ARGS_FAILURE : Arguments for 2nd level application unavailable"
ERROR_MSG[K_MODULE_RCE][11] = "ERR_BAD_BIN_FMT_VER : Binary format version does not match"
ERROR_MSG[K_MODULE_RCE][12] = "ERR_SLA_VER_NOT_SUPPORTED : SLA version is not supported"
ERROR_MSG[K_MODULE_RCE][13] = "ERR_BOOTSRC_NOT_SUPPORTED : Boot source not supported"
ERROR_MSG[K_MODULE_RCE][14] = "ERR_KEYID_NOT_SUPPORTED : Key ID not supported"
ERROR_MSG[K_MODULE_RCE][15] = "ERR_SECURITY_CHECK_NOT_SUPPORTED : Security check method not supported"
ERROR_MSG[K_MODULE_RCE][16] = "ERR_BANK_OUT_OF_RANGE :  Internal flash bank number does not exist"
ERROR_MSG[K_MODULE_RCE][17] = "ERR_NO_BIN_LOC : No binary location"
ERROR_MSG[K_MODULE_RCE][18] = "ERR_PATCH_SYNC_NO_MATCH : Patch synchronization pattern mismatch"
ERROR_MSG[K_MODULE_RCE][19] = "ERR_PATCH_BAD_ROM_VERSION : ROM Version mismatch"
ERROR_MSG[K_MODULE_RCE][20] = "ERR_PATCH_BAD_SIZE : Erroneous patch size"
ERROR_MSG[K_MODULE_RCE][21] = "ERR_UNKNOWN : Generic error for unknown behavior"

################################### COMMON ########################################
ERROR_MSG[K_MODULE_COMMON][1] = "ERR_INVAL : Value is not appropriate"
ERROR_MSG[K_MODULE_COMMON][2] = "ERR_NULL_PTR : Pointer is null"
ERROR_MSG[K_MODULE_COMMON][3] = "ERR_OUT_OF_RANGE : Value is out of expected range"
ERROR_MSG[K_MODULE_COMMON][4] = "ERR_NOT_INITIALIZED : Module not initialized"
ERROR_MSG[K_MODULE_COMMON][5] = "ERR_ALREADY_INITIALIZED : Module already initialized"
ERROR_MSG[K_MODULE_COMMON][6] = "ERR_FATAL_ERROR : Critical error"
ERROR_MSG[K_MODULE_COMMON][7] = "ERR_RUNNING: Still processing"
ERROR_MSG[K_MODULE_COMMON][8] = "ERR_BAD_STATE: Action not allowed in this state"
ERROR_MSG[K_MODULE_COMMON][9] = "ERR_NO_MATCH: Data does not match"
ERROR_MSG[K_MODULE_COMMON][10] = "ERR_NOT_SUPPORTED: Operation is not supported"
ERROR_MSG[K_MODULE_COMMON][11] = "ERR_RESET_ASKED: Error Code: Platform reset asked"
ERROR_MSG[K_MODULE_COMMON][12] = "SHUTDOWN_ASKED: Platform shutdown asked"
ERROR_MSG[K_MODULE_COMMON][13] = "ERR_UNKNOWN: Generic error for unkown behavior"


###################################################################################
