package com.maxifier.teamcity.trigger;

import jetbrains.buildServer.buildTriggers.BuildTriggerDescriptor;
import jetbrains.buildServer.buildTriggers.BuildTriggerException;
import jetbrains.buildServer.buildTriggers.BuildTriggeringPolicy;
import jetbrains.buildServer.buildTriggers.PolledBuildTrigger;
import jetbrains.buildServer.buildTriggers.PolledTriggerContext;
import jetbrains.buildServer.buildTriggers.scheduler.SchedulerBuildTriggerService;
import jetbrains.buildServer.log.Loggers;
import jetbrains.buildServer.serverSide.BatchTrigger;
import jetbrains.buildServer.serverSide.BuildCustomizer;
import jetbrains.buildServer.serverSide.BuildCustomizerFactory;
import jetbrains.buildServer.serverSide.BuildServerListener;
import jetbrains.buildServer.serverSide.InvalidProperty;
import jetbrains.buildServer.serverSide.PropertiesProcessor;
import jetbrains.buildServer.serverSide.SBuildType;
import jetbrains.buildServer.users.SUser;
import jetbrains.buildServer.util.EventDispatcher;
import jetbrains.buildServer.web.openapi.PluginDescriptor;

import java.util.Collection;
import java.util.Map;
import java.util.logging.Logger;

/**
 * @author aleksey.didik@maxifier.com (Aleksey Didik)
 */
public class GitScheduledBuildTrigger extends SchedulerBuildTriggerService {

    private static final Logger LOG = Logger.getLogger(Loggers.VCS_CATEGORY);

    public static final String GIT_BRANCH_NAME = "branchName";
    public static final String DEFAULT_BRANCH = "master";
    private final PluginDescriptor pluginDescriptor;

    private ThreadLocal<String> handoff = new ThreadLocal<String>();

    public GitScheduledBuildTrigger(PluginDescriptor pluginDescriptor,
                                    EventDispatcher<BuildServerListener> buildServerListenerEventDispatcher,
                                    BatchTrigger batchTrigger,
                                    BuildCustomizerFactory buildCustomizerFactory) {
        super(buildServerListenerEventDispatcher, batchTrigger, buildCustomizerFactory);
        this.pluginDescriptor = pluginDescriptor;

        LOG.info("Start of Git scheduling build trigger");
    }

    @Override
    public String getName() {
        return "gitSchedulingTrigger";
    }

    @Override
    public String getDisplayName() {
        return "Git Scheduling Trigger";
    }

    @Override
    public String describeTrigger(BuildTriggerDescriptor buildTriggerDescriptor) {
        return String.format("%s%nFor git branch: '%s'", super.describeTrigger(buildTriggerDescriptor),
                buildTriggerDescriptor.getProperties().get(GIT_BRANCH_NAME));
    }

    @Override
    public String getEditParametersUrl() {
        return pluginDescriptor.getPluginResourcesPath("editGitSchedulingTrigger.jsp");
    }

    @Override
    public boolean isMultipleTriggersPerBuildTypeAllowed() {
        return true;
    }

    @Override
    public BuildTriggeringPolicy getBuildTriggeringPolicy() {
        final PolledBuildTrigger policy = (PolledBuildTrigger) super.getBuildTriggeringPolicy();

        return new PolledBuildTrigger() {
            @Override
            public void triggerBuild(PolledTriggerContext polledTriggerContext) throws BuildTriggerException {

                policy.triggerBuild(polledTriggerContext);
            }
        };
    }

    @Override
    public PropertiesProcessor getTriggerPropertiesProcessor() {
        final PropertiesProcessor superProcessor = super.getTriggerPropertiesProcessor();

        return new PropertiesProcessor() {
            @Override
            public Collection<InvalidProperty> process(Map<String, String> properties) {
                Collection<InvalidProperty> superInvalid = superProcessor.process(properties);
                String gitBranchName = properties.get(GIT_BRANCH_NAME);
                if (gitBranchName == null || gitBranchName.isEmpty()) {
                    superInvalid.add(new InvalidProperty(GIT_BRANCH_NAME, "Git branch should be specified"));
                }
                return null;
            }
        };
    }

    @Override
    public Map<String, String> getDefaultTriggerProperties() {
        Map<String, String> defaultProps = super.getDefaultTriggerProperties();
        defaultProps.put(GIT_BRANCH_NAME, DEFAULT_BRANCH);
        return defaultProps;
    }

    class BranchBuildCustomizerFactory implements BuildCustomizerFactory {

        BuildCustomizerFactory delegate;

        BranchBuildCustomizerFactory(BuildCustomizerFactory delegate) {
            this.delegate = delegate;
        }



        @Override
        public BuildCustomizer createBuildCustomizer(SBuildType sBuildType, SUser sUser) {
            BuildCustomizer buildCustomizer = delegate.createBuildCustomizer(sBuildType, sUser);
            buildCustomizer.setDesiredBranchName(handoff.get());
            return buildCustomizer;
        }
    }

}
