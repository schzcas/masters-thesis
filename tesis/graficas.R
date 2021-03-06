library(ggplot2)
library(grid)
library(ggthemes)
library(dplyr)
library(igraph)
library(RGoogleAnalytics)
library(knitr)
library(tidyr)

# Auxiliares --------------------------------------------------------------

circleFun <- function(center = c(0,0),diameter = 1, npoints = 100){
  r = diameter / 2
  tt <- seq(0,2*pi,length.out = npoints)
  xx <- center[1] + r * cos(tt)
  yy <- center[2] + r * sin(tt)
  return(data.frame(x = xx, y = yy))
}

## Similitud
aux <- data.frame(x = c('BEACH','BUSINESS','ENTERTAINMENT','CONVENIENCE'),
                  y = c(0.1,6,10,8),
                  Hotel = rep('Original', 4))
ggplot(aux) +
  geom_bar(aes(x,y,fill=Hotel), stat='identity', position='dodge', width=0.5) +
  scale_fill_manual(values = 'black') +
  labs(title='Características del hotel original', x='', y='Número de servicios por categoría') +
  theme(axis.text.x=element_text(angle=30, hjust=1))

## Similitud (servicios)
x <- data.frame(x = c('BEACH','BUSINESS','ENTERTAINMENT','CONVENIENCE'),
                y = c(0.1,6,10,8),
                Hotel = rep('Original', 4))
y <- data.frame(x = c('BEACH','BUSINESS','ENTERTAINMENT','CONVENIENCE'),
                y = c(4,5,9,9),
                Hotel = rep('Alternativa 1', 4))
z <- data.frame(x = c('BEACH','BUSINESS','ENTERTAINMENT','CONVENIENCE'),
                y = c(0.1,3,4,4),
                Hotel = rep('Alternativa 2', 4))
aux <- rbind(
  cbind(x,div='Perfil similar', hinge='Servicios suficientes'),
  cbind(y,div='Perfil similar', hinge='Servicios suficientes'),
  cbind(x,div='Perfil similar', hinge='Servicios insuficientes'),
  cbind(z,div='Perfil similar', hinge='Servicios insuficientes'))

ggplot(aux) +
  geom_bar(aes(x,y,fill=Hotel), stat='identity', position='dodge', width=0.5) +
  scale_fill_manual(values = c('black', rgb(0.1,0.8,0.3), rgb(0.7,0.1,0.7))) +
  facet_wrap( ~ hinge) +
  labs(title='Efecto de la cantidad de servicios', x='', y='Número de servicios por categoría') +
  theme(axis.text.x=element_text(angle=30, hjust=1))



## Similitud (perfil)

x <- data.frame(x = c('BEACH','BUSINESS','ENTERTAINMENT','CONVENIENCE'),
                y = c(0.1,6,10,8),
                Hotel = rep('Original', 4))
y <- data.frame(x = c('BEACH','BUSINESS','ENTERTAINMENT','CONVENIENCE'),
                y = c(1,3,6,5),
                Hotel = rep('Alternativa 1', 4))
v <- data.frame(x = c('BEACH','BUSINESS','ENTERTAINMENT','CONVENIENCE'),
                y = c(10,10,10,10),
                Hotel = rep('Alternativa 3', 4))
aux <- rbind(
  cbind(x,div='Perfil similar', hinge='Servicios suficientes'),
  cbind(y,div='Perfil similar', hinge='Servicios suficientes'),
  cbind(x,div='Perfil diferente', hinge='Servicios suficientes'),
  cbind(v,div='Perfil diferente', hinge='Servicios suficientes'))

ggplot(aux) +
  geom_bar(aes(x,y,fill=Hotel), stat='identity', position='dodge', width=0.5) +
  scale_fill_manual(values = c('black', rgb(0.1,0.8,0.3), rgb(0.1,0.3,0.8))) +
  facet_wrap(~ div) +
  labs(title='Efecto de los perfiles', x='', y='Número de servicios por categoría') +
  theme(axis.text.x=element_text(angle=30, hjust=1))




## Similitud (servicios + perfil)


x <- data.frame(x = c('BEACH','BUSINESS','ENTERTAINMENT','CONVENIENCE'),
                y = c(0.1,6,10,8),
                Hotel = rep('Original', 4))
y <- data.frame(x = c('BEACH','BUSINESS','ENTERTAINMENT','CONVENIENCE'),
                y = c(1,5,9,9),
                Hotel = rep('Alternativa 1', 4))
z <- data.frame(x = c('BEACH','BUSINESS','ENTERTAINMENT','CONVENIENCE'),
                y = c(0.1,3,4,4),
                Hotel = rep('Alternativa 2', 4))
v <- data.frame(x = c('BEACH','BUSINESS','ENTERTAINMENT','CONVENIENCE'),
                y = c(10,10,10,10),
                Hotel = rep('Alternativa 3', 4))
w <- data.frame(x = c('BEACH','BUSINESS','ENTERTAINMENT','CONVENIENCE'),
                y = c(10,9,2,4),
                Hotel = rep('Alternativa 4', 4))

aux <- rbind(
  cbind(x,div='Perfil similar', hinge='Servicios suficientes'),
  cbind(y,div='Perfil similar', hinge='Servicios suficientes'),
  cbind(x,div='Perfil similar', hinge='Servicios insuficientes'),
  cbind(z,div='Perfil similar', hinge='Servicios insuficientes'),
  cbind(x,div='Perfil diferente', hinge='Servicios suficientes'),
  cbind(v,div='Perfil diferente', hinge='Servicios suficientes'),
  cbind(x,div='Perfil diferente', hinge='Servicios insuficientes'),
  cbind(w,div='Perfil diferente', hinge='Servicios insuficientes'))

ggplot(aux) +
  geom_bar(aes(x,y,fill=Hotel), stat='identity', position='dodge', width=0.5) +
  scale_fill_manual(values = c('black', rgb(0.1,0.8,0.3),
                               rgb(0.7,0.1,0.7), rgb(0.1,0.3,0.8), rgb(1,0.2,0.1))) +
  facet_grid(div ~ hinge) +
  labs(title='Características combinadas: perfil + servicios', x='', y='Número de servicios por categoría') +
  theme(axis.text.x=element_text(angle=30, hjust=1))

## Elección de alpha
set.seed(1234)
n <- 100
x <- rbeta(n, shape1 = 8, shape2 = 2)
qplot(x)
y <- 3*x - 2 + rnorm(n, 0, 0.1)
d <- data.frame(x,y) %>%
  filter(x > 0, x < 1, y > 0, y < 1)
mx <- mean(x)
my <- mean(y)
arr <- data.frame(x = rep(mx, 4),
                  y = rep(my, 4),
                  xend = c(0.75, 1, 1, 1),
                  yend = c(0.9, 1, my + (1-mx), 0.3))

a <- arr[3:4] - arr[1:2]
a <- a/abs(apply(a,1,sum))
arr$alpha <- as.character(round(a, 2)[,1])

a <- arr[3:4] - arr[1:2]
a <- a/apply(a,1,function(x) sqrt(sum(x*x)))
arr[c('xend','yend')] <- arr[c('x','y')] + a/4

plot_alpha <- ggplot(d) +
  geom_point(aes(x,y)) +
  geom_segment(data=arr,
               mapping=aes(x=x, xend=xend, y=y, yend=yend, color=alpha),
               size=1,
               arrow = arrow(length = unit(0.5,'cm'))) +
  geom_point(aes(x=mx, y=my), color = 'red', size = 3) +
  geom_text(aes(x=mx, y=my, label='(list(bar(x), bar(y)))'), parse = T,
            hjust=1.3) +
  xlim(0,1.01) +
  ylim(0,1.01) +
  coord_equal() +
  labs(title = 'Dirección de avance de la similitud\npara distintos valores de alpha',
       x = 'Similitud de servicios',
       y = 'Similitud de perfil')
plot_alpha

ggsave(filename = 'tesis/imagenes/alpha.pdf',
       plot = plot_alpha,
       width = 6, height = 6)


# Distancia: criterio dinámico --------------------------------------------

set.seed(1234)
x1 <- data.frame(x=c(0,rnorm(29),1.5,-1),
                 y=c(0,rnorm(29),1.2,-1.3),
                 s=c(5,2*runif(29),4,4),
                 col=c('original', rep('opciones malas',29),
                       'opciones buenas', 'opciones buenas'),
                 id='Pocos hoteles similares cercanos') %>%
  mutate(is_near = (sqrt(x^2 + y^2) < 2))

x2 <- data.frame(x=c(0,rnorm(30)),
                 y=c(0,rnorm(30)),
                 s=c(5,2*runif(10), 3 + 2*runif(20)),
                 col=c('original', rep('opciones malas',10),
                       rep('opciones buenas', 20)),
                 id='Muchos hoteles similares cercanos') %>%
  mutate(is_near = (sqrt(x^2 + y^2) < 1))
x3 <- rbind(x1,x2)
c1 <- circleFun(center = c(0,0), diameter = 2, npoints = 100)
c2 <- circleFun(center = c(0,0), diameter = 4, npoints = 100)
c3 <- rbind(cbind(c1, id='Muchos hoteles similares cercanos'),
            cbind(c2, id='Pocos hoteles similares cercanos'))

n <- 3
hues = seq(15, 375, length=n+1)
cols <- hcl(h=hues, l=65, c=100)

plot_distdin <- ggplot(x3) +
  geom_point(aes(x,y,size=s,color=col)) +
  geom_point(aes(x,y,size=s,alpha=(s>2 & is_near)), shape=1, color='black') +
  geom_path(data=c3, aes(x,y), linetype='dashed') +
  scale_color_manual(values=c(cols[2],cols[1],'blue')) +
  scale_size_continuous(guide=FALSE) +
  scale_alpha_discrete(guide=FALSE) +
  guides(color=guide_legend(title=NULL)) +
  labs(x='Longitud', y='Latitud') +
  coord_equal() +
  facet_wrap(~ id)

ggsave(filename = 'tesis/presentacion/imagenes/distdin.pdf',
       plot = plot_distdin,
       width = 8, height = 4)


# Sistema completo --------------------------------------------------------

set.seed(1234)
circ <- circleFun(c(0,0),3,npoints = 100)
x2 <- data.frame(x=c(0,rnorm(30)),
                 y=c(0,rnorm(30)),
                 s=c(5,4*runif(30))) %>%
  mutate(col=ifelse(s==5, 'Original',
                    ifelse(sqrt(x^2 + y^2) < 1.5,
                           ifelse(runif(31) < 0.5, 'Recomendados', 'Caros'),
                           'Lejanos'))) %>%
  group_by(col) %>%
  mutate(r = rank(-s)) %>%
  arrange(col, r)

plot_todo <- ggplot(x2) +
  geom_point(aes(x,y,size=s, color=col)) +
  geom_point(data=filter(x2,col=='Recomendados') %>% head(5),
             aes(x,y,size=s), color='black', shape=1) +
  scale_color_manual(values = c('Original'=rgb(0.1,0.3,0.8),
                                'Recomendados'=rgb(0.1,0.8,0.3),
                                'Caros'=rgb(0.8,0.8,0.1),
                                'Lejanos'='black')) +
  geom_path(data=circ, aes(x,y), linetype='dashed') +
  geom_text(data=filter(x2, col=='Recomendados') %>% head(5),
            aes(x,y,label=r), hjust=-1, vjust=-0.5) +
  guides(color=guide_legend(title=NULL)) +
  scale_size_continuous(guide=FALSE) +
  scale_alpha_discrete(guide=FALSE) +
  coord_equal() +
  labs(x='Longitud', y='Latitud')
plot_todo
ggsave(filename = 'tesis/presentacion/imagenes/similitud-completa.pdf',
       plot = plot_todo,
       width = 7, height = 7)

# Preparar información para Gephi -----------------------------------------

library(dplyr)
library(igraph)

load('tesis/datos/datos_gephi.Rdata')
hoteles <- read.csv('tesis/datos/Hoteles.csv', header = T, quote = '"',
                    stringsAsFactors = F) %>%
  dplyr::select(-X) %>%
  arrange(Clav_Hotel)

dim(recomendados)
head(recomendados)

h1 <- hoteles %>%
  rename(cl1=Clav_Hotel, n1=Nombre_Hotel, d1=Clav_Destino, cld1=Nombre_Destino)
h2 <- hoteles %>%
  rename(cl2=Clav_Hotel, n2=Nombre_Hotel, d2=Clav_Destino, cld2=Nombre_Destino)

red_df <- recomendados %>%
  filter(rank <= 5) %>%
  left_join(h1) %>%
  left_join(h2) %>%
  dplyr::select(from=cl1, to=cl2, km, score)
dim(red_df)
head(red_df)

red <- graph.data.frame(red_df, directed = T)
vert <- data.frame(Clav_Hotel = as.numeric(get.vertex.attribute(red, name = 'name')))
vert <- vert %>%
  left_join(hoteles, by=c('Clav_Hotel'))
red <- set.vertex.attribute(red, name = 'Nombre_Hotel', value = vert$Nombre_Hotel)
red <- set.vertex.attribute(red, name = 'Clav_Destino', value = vert$Clav_Destino)
red <- set.vertex.attribute(red, name = 'Nombre_Destino', value = vert$Nombre_Destino)
get.vertex.attribute(red, name = 'name')
get.vertex.attribute(red, name = 'Nombre_Hotel')
get.vertex.attribute(red, name = 'Clav_Destino')
get.vertex.attribute(red, name = 'Nombre_Destino')

#write.graph(red, file="tesis/datos/red2.graphml", format="graphml")

# Estadísticas de Cancún

red_cun <- induced_subgraph(red, V(red)[get.vertex.attribute(red, name = 'Clav_Destino') == 2])
average.path.length(red, directed = T, unconnected = T)
average.path.length(red, directed = F, unconnected = T)
diameter(red_cun, directed = T, unconnected = T)
plot(degree_distribution(red))


# Ejemplos Gephi ----------------------------------------------------------

df1 <- expand.grid(1:10, 1:4)
df2 <- expand.grid(11:25, 11:14)            
df3 <- expand.grid(31:50, 31:34)            
df_net <- rbind(df1, df2, df3) %>%
  as.data.frame
names(df_net) <- c('from','to')

red <- graph.data.frame(df_net, directed = T)
plot(red)
write.graph(red, file='tesis/datos/red_ejemplos.graphml', format = 'graphml')



# Analytics ---------------------------------------------------------------

oauth_token <- Auth(client.id = "410202734756-vuek66j0asrnk5aicd0geog0uf5kje2u.apps.googleusercontent.com",
                    client.secret = "81DW-mkNRQAF21-FD-89dkI2")

ValidateToken(oauth_token)

## QUERY
getdata <- function(start.date, end.date, daywise=FALSE){
  dimensions <- 'ga:userType,ga:date'
  metrics <- 'ga:users,ga:sessions,ga:bounceRate,ga:avgSessionDuration,ga:goalConversionRateAll,ga:pageviews,ga:revenuePerTransaction'
  segments_y <- 'sessions::condition::ga:pagePath=~view=(similarhotel|similarpackage)'
  segments_n <- 'sessions::condition::ga:dimension18==Hotel;condition::!ga:pagePath=~view=(similarhotel|similarpackage)'
  table.id <- 'ga:22605939'
  ##
  params_list_1 <- Init(start.date = start.date,
                        end.date = end.date,
                        dimensions = dimensions,
                        metrics = metrics,
                        segments = segments_y,
                        table.id = table.id,
                        max.results = 1000)
  ga_query_1 <- QueryBuilder(query.params.list = params_list_1)
  ga_df_1 <- GetReportData(ga_query_1, token = oauth_token, split_daywise = daywise)
  
  ###
  
  params_list_2 <- Init(start.date = start.date,
                        end.date = end.date,
                        dimensions = dimensions,
                        metrics = metrics,
                        segments = segments_n,
                        table.id = table.id,
                        max.results = 1000)
  ga_query_2 <- QueryBuilder(query.params.list = params_list_2)
  ga_df_2 <- GetReportData(ga_query_2, token = oauth_token, split_daywise = daywise)
  
  v <- ga_df_1
  nv <- ga_df_2
  # save(list = c('v', 'nv'), file = 'tesis/datos/query_api_20150101_20150913.Rdata')
  head(ga_df_1)
  head(ga_df_2)
  
  # library(lubridate)
  
  #load('datos/query_api_20150101_20150913.Rdata')
  
  
  dat <- rbind(
    data.frame(viewed_recom = 'yes', v),
    data.frame(viewed_recom = 'no', nv)
  ) %>%
    group_by(viewed_recom, date) %>%
    summarise(users = sum(users),
              bounceRate = sum(bounceRate * sessions)/sum(sessions),
              avgSessionDuration= sum(avgSessionDuration * sessions)/sum(sessions)/60,
              goalConversionRateAll = sum(goalConversionRateAll* sessions)/sum(sessions),
              pageviews = sum(pageviews),
              sessions = sum(sessions),
              avgRevenue = sum(revenuePerTransaction*sessions)/sum(sessions)) %>%
    mutate(pageviews_per_session = pageviews / sessions) %>%
    filter(!is.na(date)) %>%
    ungroup
  dat <- dat[dat$pageviews < max(dat$pageviews), ]
  
  dat$date <- strptime(dat$date, '%Y%m%d') %>%
    as.character %>%
    as.Date
  dat
}

## OBTENER INFO
dat1 <- getdata('2015-08-01', '2015-11-22', daywise = T)
dat2 <- getdata('2014-08-01', '2014-10-22', daywise = T) # Truena el 2014-10-23...
dat3 <- getdata('2014-10-24', '2014-11-22', daywise = T)
dat <- rbind(dat1, dat2, dat3)

# OJO: Hay un dato mega extremo. Así lo hago menos feo
y <- dat$avgRevenue[dat$viewed_recom == 'yes']
hist(y)
dat$avgRevenue[dat$viewed_recom == 'yes'] <- ifelse(y == max(y), mean(y[y!=max(y)]), y)

# Base en formato largo
long <- dat %>%
  gather(var, val, sessions, bounceRate, avgSessionDuration, goalConversionRateAll, pageviews_per_session, avgRevenue)

### Los que usaron recomendaciones: este año vs el anterior
aux <- long %>%
  mutate(year= as.character(year(date)),
         datediff = as.numeric(date - as.Date(paste0(year,'-08-01')))) %>%
  filter(viewed_recom=='yes')
# Ojo con el valor mega extremo el 2014-09-22
# aux %>% filter(var=='avgRevenue') %>% arrange(desc(val))
levels(aux$var) <- c('Usuarios','Tasa de rebote (%)','Duración promedio de la sesión (minutos)','Tasa de conversión (%)','Páginas vistas por sesión','Precio promedio por compra')

p <- ggplot(aux, aes(datediff, val, color=year)) +
  geom_line() +
  geom_vline(aes(xintercept=as.numeric(datediff[date=='2015-09-10'])), linetype=4) +
  geom_vline(aes(xintercept=as.numeric(datediff[date=='2015-10-10'])), linetype=4) +
  geom_vline(aes(xintercept=as.numeric(datediff[date=='2015-11-10'])), linetype=4) +
  geom_smooth() +
  facet_wrap(~ var, scales = 'free_y', ncol = 2) +
  #theme(axis.text.x = element_text(angle=90)) +
  scale_x_continuous(breaks=c(0,20,40,70,101), labels=format.Date(as.Date('2015-08-01') + c(0,20,40,70,101), '%d/%b')) +
  scale_color_discrete(name='Año') +
  #scale_x_date() +
  labs(x='', y='', title='Indicadores para usuarios que utilizaron el sistema')
p

# ggsave('tesis/imagenes/analytics_anios_x.pdf', p, scale = 1, width = 8, height = 8, units = 'in')


### Los que vieron como proporción de los que no

dat3 <- inner_join(filter(dat, viewed_recom == 'no'),
                   filter(dat, viewed_recom == 'yes'),
                   by = c('date')) %>%
  dplyr::select(-viewed_recom.x,-viewed_recom.y)

for(col in names(dat)[!(names(dat) %in% c('date','viewed_recom'))]){
  dat3[[paste0('p_',col)]] <- ifelse(dat3[[paste0(col,'.x')]] == 0,
                                     -1,
                                     dat3[[paste0(col,'.y')]]/dat3[[paste0(col,'.x')]])
}

dat4 <- dat3 %>%
  dplyr::select(date, p_users, p_bounceRate, p_avgSessionDuration, p_goalConversionRateAll, p_pageviews_per_session, p_avgRevenue) %>%
  gather(var, value, p_users:p_avgRevenue)

aux <- dat4 %>%
  mutate(year= as.character(year(date)),
         datediff = as.numeric(date - as.Date(paste0(year,'-08-01'))))
levels(aux$var) <- c('Usuarios','Tasa de rebote (%)','Duración promedio de la sesión (minutos)','Tasa de conversión (%)','Páginas vistas por sesión','Precio promedio por compra')
  
p <- ggplot(aux, aes(datediff, value, color=year)) +
  geom_line() +
  geom_vline(aes(xintercept=as.numeric(datediff[date=='2015-09-10'])), linetype=4) +
  geom_vline(aes(xintercept=as.numeric(datediff[date=='2015-10-10'])), linetype=4) +
  geom_vline(aes(xintercept=as.numeric(datediff[date=='2015-11-10'])), linetype=4) +
  geom_smooth() +
  theme(axis.text.x = element_text(angle=90)) +
  scale_x_continuous(breaks=c(0,20,40,70,101), labels=format.Date(as.Date('2015-08-01') + c(0,20,40,70,101), '%d/%b')) +
  scale_color_discrete(name='Año') +
  #scale_x_date() +
  facet_wrap(~var, scales = 'free_y', ncol=2) +
  labs(x='Fecha',y='',title='Indicadores cociente: con vs. sin sistema')
p
# ggsave('tesis/imagenes/analytics_anios_y.pdf', p, scale = 1, width = 8, height = 8, units = 'in')




### Pruebas y presentación


aa <- aux %>% filter(((aux$var=='Precio promedio por compra') & (aux$val < 3000)) | (aux$var !='Precio promedio por compra'))

ggplot(aux, aes(datediff, val, color=year)) +
  geom_line() +
  geom_vline(aes(xintercept=as.numeric(datediff[date=='2015-09-10'])), linetype=4) +
  geom_vline(aes(xintercept=as.numeric(datediff[date=='2015-10-10'])), linetype=4) +
  geom_vline(aes(xintercept=as.numeric(datediff[date=='2015-11-10'])), linetype=4) +
  geom_smooth() +
  facet_wrap(~ var, scales = 'free_y', ncol = 2) +
  #theme(axis.text.x = element_text(angle=90)) +
  scale_x_continuous(breaks=c(0,20,40,70,101), labels=format.Date(as.Date('2015-08-01') + c(0,20,40,70,101), '%d/%b')) +
  scale_color_discrete(name='Año') +
  #scale_x_date() +
  labs(x='', y='', title='Indicadores para usuarios que utilizaron el sistema')


ggplot(aux %>% filter(var == 'Precio promedio por compra'), aes(datediff, value, color=year)) +
  geom_line() +
  geom_vline(aes(xintercept=as.numeric(datediff[date=='2015-09-10'])), linetype=4) +
  geom_vline(aes(xintercept=as.numeric(datediff[date=='2015-10-10'])), linetype=4) +
  geom_vline(aes(xintercept=as.numeric(datediff[date=='2015-11-10'])), linetype=4) +
  geom_smooth() +
  theme(axis.text.x = element_text(angle=90)) +
  scale_x_continuous(breaks=c(0,20,40), labels=format.Date(as.Date('2015-08-01') + c(0,20,40), '%d/%b')) +
  scale_color_discrete(name='Año') +
  #scale_x_date() +
  facet_wrap(~var, scales = 'free_y', ncol=2) +
  ylim(0,2) +
  labs(x='Fecha',y='',title='Indicadores cociente: con vs. sin sistema')


