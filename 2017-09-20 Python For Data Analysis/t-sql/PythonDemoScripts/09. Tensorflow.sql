execute sp_execute_external_script 
@language = N'Python',
@script = N'
import tensorflow as tf
hello = tf.constant("Hello, tensorflow!")
sess = tf.Session()
print(sess.run(hello))
'
GO