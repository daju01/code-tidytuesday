library(tidyverse)
library(statebins)
library(socviz)

# Get data ----------------------------------------------------------------

dat_path <- "data/24-cats-and-dogs.Rdata"


if(!file.exists(dat_path)) {
  dat <- read_csv(paste0("https://raw.githubusercontent.com/",
                  "rfordatascience/tidytuesday/master/data/",
                  "2018-09-11/cats_vs_dogs.csv")) %>%
    select(-X1)
  save(dat, file = dat_path)
} else {
  load(dat_path)
}


# plot --------------------------------------------------------------------

# code tries to replicate:
# https://socviz.co/maps.html#map-u.s.-state-level-data

# get the census column from socviz
# to facet regions

tst <- dat %>%
  left_join(socviz::election %>%
              select(state, census)) %>%
  mutate(ratio_owner = n_dog_households/n_cat_households,
         main_household = case_when(ratio_owner > 1 ~ "Dog",
                                    ratio_owner < 1 ~ "Cat",
                                    TRUE ~ "Both"),
         main_household = factor(main_household,
                                 levels = c("Cat", "Both", "Dog")))


png(filename = "plots/24-cats-and-dogs.png",
    height = 2500, width = 1700,
    res = 300)
tst %>%
  ggplot(aes(x = reorder(state, ratio_owner),
             y = ratio_owner,
             colour = main_household)) +
  geom_hline(yintercept = 1) +
  geom_point(size = 2) +
  facet_grid(census ~ .,
             scales = "free_y",
             space = "free") +
  scale_color_viridis_d(begin = .1, end = .9) +
  coord_flip() +
  scale_y_log10(limits = c(.6, 1.7),
                breaks = c(.625, .8, 1, 1.25, 1.6),
                labels = c("x1.6\n (Cat)", "x1.25", "1", "x1.25", "x1.6\n(Dog)")) +
  theme_minimal() +
  theme(axis.text.x = element_text(size = 12)) +
  labs(title = "Households with Cats and/or Dogs",
       subtitle = "In the US, split by region",
       x = "",
       y = "Household Ratio", 
       colour = "Preferred Pet",
       caption = "Source: data.world, plot by @othomn")
dev.off()


# A slightly different take -----------------------------------------------


png(filename = "plots/24-cats-and-dogs-2nd-take.png",
    height = 2500, width = 1600,
    res = 300)
tst %>%
  select(state, census,
         percent_dog_owners, percent_cat_owners) %>%
  gather(percent_dog_owners:percent_cat_owners,
         key = pet,
         value = percent) %>%
  mutate(pet = case_when(pet == "percent_dog_owners" ~ "Dog",
                         pet == "percent_cat_owners" ~ "Cat")) %>% 
  ggplot(aes(x = reorder(state, percent),
             y = percent,
             fill = pet,
             pch = pet)) +
  geom_line(aes(group = state), colour = "grey") +
  # geom_hline(yintercept = 1) +
  geom_point(size = 2,
             alpha = 1) +
  facet_grid(census ~ .,
             scales = "free_y",
             space = "free") +
  scale_fill_viridis_d(begin = .1, end = .9,
                       guide = guide_legend(title = "Pet owned")) +
  scale_shape_manual(values = c(21, 23),
                     guide = guide_legend(title = "Pet owned")) +
  coord_flip() +
  scale_y_continuous(breaks = 1:5*10,
                     labels = c(paste0(1:5*10, "%"))) +
  theme_minimal() +
  # guides(shape = guide_legend())
  labs(title = "Households with Cats and/or Dogs",
       subtitle = "In the US, split by region",
       x = "",
       y = "Pet Owners [% of Households]", 
       fill = "Preferred Pet",
       caption = "Source: data.world, plot by @othomn")
dev.off()
  



