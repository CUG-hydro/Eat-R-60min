#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "CUG水文气象学2025", header: "")

#show "{": ""
#show "}": ""


= 存在截距

#mitex(`$$
\theta(t) = S_0 e^{-kt} + \theta_r
$$`)

#mitex(`$$
\frac{d\theta}{dt} = -k S_0 e^{-kt}
$$`)

#mitex(`$$
\frac{d\theta}{dt} = -k (\theta(t) - \theta_r) = -k\theta(t) + k\theta_r
$$`)

= 无截距

$
  theta(t) = S_0 e^{-k t}
$

$ dv(theta, t) = -k theta ==> (d theta) / theta = -k d t $

$ 
  ln theta = -k t + C \
  theta = e^C e^{-k t} = S_0 e^{-k t}
$
