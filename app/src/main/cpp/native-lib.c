#include <string.h>
#include <jni.h>

JNIEXPORT jbyteArray JNICALL
Java_de_be_thaw_encryption_SecretKeyGen_getSecretKey(JNIEnv *env,
													 jobject thiz) {
	jbyte a[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
	jbyteArray ret = (*env)->NewByteArray(env, 16);
	(*env)->SetByteArrayRegion(env, ret, 0, 16, a);
	return ret;
}