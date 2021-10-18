
# NOTE: UNTESTED !


library(tidyverse)
library(lubridate)
library(janitor)
# DEADLY SERIOUS (EXCELENT COLOUR PALETTE FOR 8+ CATEGORIES, AS HERE):
# remotes::install_github("asteves/tayloRswift")
library(tayloRswift)


# 0. SET FACTOR LEVELS ----------------------------------------------------

tag_levels_ts <- c(
  "structured\nreview",
  "initial\nopinion",
  "diagnostic\nprocedure",
  "treatment",
  "urgent\ninvestigation",
  "discuss\nresults",
  "pre-op",
  "post-op",
  "review\nNEL",
  "direct\naccess"
)


# 1. WRANGLE ---------------------------------------------------------------

df_viz <- df_summary %>%
  filter(as_date(ym) >= as_date("2019-04-01") & as_date(ym) <= as_date("2020-03-31")) %>%
  # SET YOUR PARAMS:
  filter(site %in% c("RR101", "RXK01", "RRK15")) %>%
  mutate(site = case_when(
    site == "RR101" ~ "Heartlands",
    site == "RXK01" ~ "Sandwell\nGeneral",
    site == "RRK15" ~ "Queen\nElizabeth",
    T ~ NA_character_
  )) %>%
  count(site, tag, wt = n, sort = T) %>%
  # ADD DUMMY FACTOR LEVEL SO COLOUR SCALES WILL BE CONSISTENT EVEN WITH ABSENCE OF DIRECT ACCESS
  bind_rows(set_names(rep(NA, ncol(.)), colnames(.)) %>% enframe() %>% pivot_wider() %>% mutate(tag = "direct_access") %>% mutate(n = 0)) %>%
  # ADJUST TAG NAMES FOR BETER PRINTING:
  mutate(tag = case_when(
    tag == "structured_review" ~ "structured\nreview",
    tag == "initial_opinion" ~ "initial\nopinion",
    tag == "diagnostic" ~ "diagnostic\nprocedure",
    tag == "treatment" ~ "treatment",
    tag == "discuss_results" ~ "discuss\nresults",
    tag == "urgent_investigation" ~ "urgent\ninvestigation",
    # tag == "urgent_procedure" ~ "urgent\ninvestigation",
    tag == "review_nel" ~ "review\nNEL",
    tag == "pre_op" ~ "pre-op",
    tag == "post_op" ~ "post-op",
    tag == "direct_access" ~ "direct\naccess",
    T ~ tag
  )) %>%
  mutate(tag = fct_relevel(tag, levels = tag_levels_ts)) %>%
  group_by(site) %>%
  mutate(p = n / sum(n)) %>%
  mutate(tf_sum = sum(n)) %>%
  ungroup() %>%
  # mutate(pop = (tf_sum/max(tf_sum))) %>% # count(provider, tf_sum, pop)# print(n=42)
  mutate(p_order = ifelse(tag == "structured\nreview", p, 0))


# 2. GGPLOT ---------------------------------------------------------------

df_viz %>%
  ggplot() +
  theme_minimal() +
  geom_point(aes(x = reorder(site, p_order), y = -.05, size = tf_sum), show.legend = F, alpha = 0.025) +
  geom_bar(
    stat = "identity", colour = "grey",
    aes(x = reorder(site, p_order), y = (p), fill = fct_rev(tag))
  ) + # , alpha = .45
  geom_text(aes(x = reorder(site, p_order), y = -.05, label = scales::comma(tf_sum)), size = 3, nudge_x = -.25, family = "Source Serif 4", colour = "grey50") + # , hjust=0, vjust=0
  labs(fill = "Function of attendance") +
  guides(fill = guide_legend(
    reverse = T,
    title.position = "top",
    label.position = "bottom",
    keywidth = 3,
    nrow = 1
  )) +
  theme(
    legend.position = "top",
    axis.title = element_blank(),
    legend.title = element_text(family = "Source Serif 4"), # , colour = "grey30"
    legend.text = element_text(family = "Source Serif 4"),
    axis.text = element_text(family = "Source Serif 4")
  ) +
  scale_y_continuous(labels = scales::percent) +
  # viridis::scale_fill_viridis(discrete = TRUE, direction = -1) +
  # scale_fill_discrete(direction = -1) +
  scale_fill_taylor(
    palette = "lover",
    # guide = "none"
    discrete = T,
    reverse = T
  ) +
  scale_size_continuous(
    trans = "identity",
    # USE RATIO - MIN TO MAX N (THIS COULD BE MADE AUTOMATIC)
    range = c(19689 / 49909 * 10, 10),
    # labels = scales::comma
  ) +
  coord_flip() +
  ggsave("example_graphic.png", width = 20, height = 10, units = "cm", dpi = 500)

