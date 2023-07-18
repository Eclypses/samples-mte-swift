/*
Copyright (c) Eclypses, Inc.

All rights reserved.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
#ifndef mte_wrap_mke_dec_h
#define mte_wrap_mke_dec_h

#ifndef mte_wrap_base_h
#include "mte_wrap_base.h"
#endif

/* This wraps the MTE Managed-Key Encryption add-on decoder functions.

   To use with a dynamic library, compile with MTE_BUILD_SHARED defined.
*/
#ifdef __cplusplus
extern "C"
{
#endif

/* Returns the decoder state size for the given DRBG algorithm, token size in
   bytes, verifiers algorithm, and cipher/hash algorithms. Returns 0 if the
   combination is not usable. */
MTE_SHARED
MTE_UINT32_T mte_wrap_mke_dec_state_bytes(mte_drbgs drbg,
                                          MTE_UINT32_T tok_bytes,
                                          mte_verifiers verifiers,
                                          mte_ciphers cipher,
                                          mte_hashes hash);

/* Initialize the decoder state given the DRBG algorithm, token size in bytes,
   verifiers algorithm, cipher/hash algorithms, timestamp window, and sequence
   window. Returns the status.

   If a sequencing verifier is used, s_window has the following properties:
     a. If s_window == 0, any message out of sequence is flagged as an error
        before attempting decode.
     b. If -63 <= s_window <= -1, any message that comes out of sequence within
        abs(s_window) messages will be decoded, but the state is not advanced,
        so an earlier message can be decoded later. If a message comes out of
        sequence more than abs(s_window) ahead but no more than 2*abs(s_window)
        ahead, the message will be decoded and the state is advanced so the
        sequence number received is now only abs(s_window) ahead; any messages
        that come in before the base sequence number are flagged as an error
        before attempting to decode.
     c. If s_window > 0, any message that comes out of sequence within s_window
        messages will be decoded and the state is advanced so the sequence
        number received is now the base sequence number; any messages that come
        in before the new base sequence number are flagged as an error before
        attempting to decode.

   The state buffer must be of sufficient length to hold the decoder state. See
   mte_wrap_mke_dec_state_bytes(). */
MTE_SHARED
mte_status mte_wrap_mke_dec_state_init(MTE_HANDLE state,
                                       mte_drbgs drbg,
                                       MTE_UINT32_T tok_bytes,
                                       mte_verifiers verifiers,
                                       mte_ciphers cipher,
                                       mte_hashes hash,
                                       MTE_UINT64_T t_window,
                                       MTE_INT32_T s_window);

/* Instantiate the decoder given the entropy input callback/context, nonce
   callback/context, personalization string, and length of the personalization
   string in bytes. Returns the status. */
MTE_SHARED
mte_status mte_wrap_mke_dec_instantiate(MTE_HANDLE state,
                                        mte_wrap_get_entropy_input ei_cb,
                                        void *ei_cb_context,
                                        mte_wrap_get_nonce n_cb,
                                        void *n_cb_context,
                                        const void *ps, MTE_UINT32_T ps_bytes);

/* Returns the state save size [raw]. Returns 0 if save is unsupported. */
MTE_SHARED
MTE_UINT32_T mte_wrap_mke_dec_save_bytes(MTE_CHANDLE state);

/* Returns the state save size [Base64-encoded]. Returns 0 if save is
   unsupported. */
MTE_SHARED
MTE_UINT32_T mte_wrap_mke_dec_save_bytes_b64(MTE_CHANDLE state);

/* Save the decoder state to the given buffer encoded in Base64. The size of
   the buffer must be mte_wrap_mke_dec_save_bytes_b64() and the result is null-
   terminated. Returns mte_status_unsupported if not supported; otherwise
   returns mte_status_success. */
MTE_SHARED
mte_status mte_wrap_mke_dec_state_save_b64(MTE_CHANDLE state, void *saved);

/* Restore the decoder state from the given buffer in raw form. Returns
   mte_status_unsupported if not supported; otherwise returns
   mte_status_success. */
MTE_SHARED
mte_status mte_wrap_mke_dec_state_restore_b64(MTE_HANDLE state,
                                              const void *saved);

/* Returns the decode buffer size [raw] in bytes given the encoded length in
   bytes. Returns 0 if the input is invalid. The decode buffer provided to
   mte_wrap_mke_dec_decode() must be of at least this length. */
MTE_SHARED MTE_WASM_EXPORT
MTE_UINT32_T mte_wrap_mke_dec_buff_bytes(MTE_CHANDLE state,
                                         MTE_UINT32_T encoded_bytes);

/* Returns the decode buffer size [Base64-encoded] in bytes given the encoded
   length in bytes. The decode buffer provided to mte_wrap_mke_dec_decode_b64() must
   be of at least this length. */
MTE_SHARED
MTE_UINT32_T mte_wrap_mke_dec_buff_bytes_b64(MTE_CHANDLE state,
                                             MTE_UINT32_T encoded_bytes);

/* Decode the given raw encoded data to the given decode buffer. Returns the
   status. Sets *decoded_off to the offset in the decoded buffer where the
   decoded version can be found and sets *decoded_bytes to the decoded data
   length in bytes. The decoded version is valid only if the status indicates
   success or a non-fatal error. A null terminator is appended to the decoded
   data, but is not included in *decoded_bytes. The encode/decode timestamps
   and messages skipped are loaded or set to 0 depending on the verifiers in
   use.

   The timestamp callback and context are used to obtain the timestamp if the
   timestamp verifier is enabled.

   The decoded buffer must be of sufficient length to hold the decoded version.
   See mte_wrap_mke_dec_buff_bytes(). */
MTE_SHARED
mte_status mte_wrap_mke_dec_decode(MTE_HANDLE state,
                                   mte_verifier_get_timestamp64 t_cb,
                                   void *t_cb_context,
                                   const void *encoded,
                                   MTE_UINT32_T encoded_bytes,
                                   void *decoded,
                                   MTE_UINT32_T *decoded_off,
                                   MTE_UINT32_T *decoded_bytes,
                                   MTE_UINT64_T *enc_ts,
                                   MTE_UINT64_T *dec_ts,
                                   MTE_UINT32_T *msg_skipped);

/* Decode the given Base64-encoded encoded data to the given decode buffer.
   Returns the status. Sets *decoded_off to the offset in the decoded buffer
   where the decoded version can be found and sets *decoded_bytes to the decoded
   data length in bytes. The decoded version is valid only if the status
   indicates success or a non-fatal error. A null terminator is appended to the
   decoded data, but is not included in *decoded_bytes. The encode/decode
   timestamps and messages skipped are loaded or set to 0 depending on the
   verifiers in use.

   The timestamp callback and context are used to obtain the timestamp if the
   timestamp verifier is enabled.

   The decoded buffer must be of sufficient length to hold the decoded version.
   See mte_wrap_mke_dec_buff_bytes_b64(). */
MTE_SHARED
mte_status mte_wrap_mke_dec_decode_b64(MTE_HANDLE state,
                                       mte_verifier_get_timestamp64 t_cb,
                                       void *t_cb_context,
                                       const void *encoded,
                                       MTE_UINT32_T encoded_bytes,
                                       void *decoded,
                                       MTE_UINT32_T *decoded_off,
                                       MTE_UINT32_T *decoded_bytes,
                                       MTE_UINT64_T *enc_ts,
                                       MTE_UINT64_T *dec_ts,
                                       MTE_UINT32_T *msg_skipped);

/* Returns the chunk-based decryption state size in bytes. The c_state buffer
   provided to the mte_wrap_mke_dec_decrypt_*() functions must be of at least this
   length. */
MTE_SHARED
MTE_UINT32_T mte_wrap_mke_dec_decrypt_state_bytes(MTE_CHANDLE state);

/* Decrypt a chunk of data in a chunk-based decryption session. The encrypted
   data of length encrypted_bytes is used as input and some decrypted data is
   written to the decrypted buffer and *decrypted_bytes is set to the amount of
   decrypted data written. The amount decrypted may be less than the input size.
   Returns the status.

   The decrypted buffer must be at least encrypted_bytes plus the cipher block
   size bytes in length to hold the decrypted version. The decrypted buffer
   cannot overlap the encrypted buffer. */
MTE_SHARED
mte_status mte_wrap_mke_dec_decrypt_chunk(MTE_HANDLE state, MTE_HANDLE c_state,
                                          const void *encrypted,
                                          MTE_UINT32_T encrypted_bytes,
                                          void *decrypted,
                                          MTE_UINT32_T *decrypted_bytes);

/* Finish the chunk-based decryption session. Returns the status. Writes the
   final decrypted data to the c_state buffer and sets *decrypted_off to the
   offset in the c_state buffer of the final decrypted data and sets
   *decrypted_bytes to the length of the final part of the decrypted data. The
   c_state is no longer usable for a chunk-based decryption session until
   mte_wrap_mke_dec_decrypt_start() is called. The encode/decode timestamps and
   messages skipped are loaded or set to 0 depending on the verifiers in use.

   The timestamp callback and context are used to obtain the timestamp if the
   timestamp verifier is enabled. */
MTE_SHARED
mte_status mte_wrap_mke_dec_decrypt_finish(MTE_HANDLE state, MTE_HANDLE c_state,
                                           mte_verifier_get_timestamp64 t_cb,
                                           void *t_cb_context,
                                           MTE_UINT32_T *decrypted_off,
                                           MTE_UINT32_T *decrypted_bytes,
                                           MTE_UINT64_T *enc_ts,
                                           MTE_UINT64_T *dec_ts,
                                           MTE_UINT32_T *msg_skipped);

#ifdef __cplusplus
}
#endif

#endif

