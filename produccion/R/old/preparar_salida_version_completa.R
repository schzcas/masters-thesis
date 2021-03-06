
out <- recomendados %>%
#   mutate(within_price = (p2 < p1 * (1 + 0.3))) %>% # En la version rápida se filtra por precio desde aquí
  group_by(cl1) %>%
#   mutate(nrec = sum(within_price)) %>%
#   filter(((nrec >= max_num_recom) & within_price) | (nrec < max_num_recom)) %>%
#   top_n(n = max_num_recom, desc(rank)) %>%
#   arrange(cl1, rank) %>%
  dplyr::select(Clav_Hotel=cl1, Clav_HotelRecomendacion=cl2) %>%
  mutate(Prioridad = row_number()) %>%
  ungroup

