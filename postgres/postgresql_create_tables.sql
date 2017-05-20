-- Table: public.prefix_nodes

-- DROP TABLE public.prefix_nodes;

CREATE TABLE public.prefix_nodes
(
  id integer NOT NULL DEFAULT nextval('prefix_nodes_id_seq'::regclass),
  parent_id integer,
  name character varying(255),
  "order" integer,
  is_deleted boolean NOT NULL DEFAULT false,
  CONSTRAINT prefix_nodes_pkey1 PRIMARY KEY (id),
  CONSTRAINT prefix_nodes_parent_id_fkey FOREIGN KEY (parent_id)
      REFERENCES public.prefix_nodes (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.prefix_nodes
  OWNER TO postgres;

-- Index: public.prefix_nodes_parent_id_index

-- DROP INDEX public.prefix_nodes_parent_id_index;

CREATE INDEX prefix_nodes_parent_id_index
  ON public.prefix_nodes
  USING btree
  (parent_id);


-- Table: public.prefix_nodes_paths

-- DROP TABLE public.prefix_nodes_paths;

CREATE TABLE public.prefix_nodes_paths
(
  id integer NOT NULL DEFAULT nextval('prefix_nodes_paths_id_seq'::regclass),
  ancestor_id integer,
  descendant_id integer,
  depth integer,
  CONSTRAINT prefix_nodes_paths_pkey PRIMARY KEY (id),
  CONSTRAINT prefix_nodes_paths_ancestor_id_fkey FOREIGN KEY (ancestor_id)
      REFERENCES public.prefix_nodes (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT prefix_nodes_paths_descendant_id_fkey FOREIGN KEY (descendant_id)
      REFERENCES public.prefix_nodes (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.prefix_nodes_paths
  OWNER TO postgres;

-- Index: public.prefix_nodes_paths_ancestor_id_index

-- DROP INDEX public.prefix_nodes_paths_ancestor_id_index;

CREATE INDEX prefix_nodes_paths_ancestor_id_index
  ON public.prefix_nodes_paths
  USING btree
  (ancestor_id);

-- Index: public.prefix_nodes_paths_descendant_id_index

-- DROP INDEX public.prefix_nodes_paths_descendant_id_index;

CREATE INDEX prefix_nodes_paths_descendant_id_index
  ON public.prefix_nodes_paths
  USING btree
  (descendant_id);


